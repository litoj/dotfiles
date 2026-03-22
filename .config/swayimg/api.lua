---@meta swi

---@class override
---@field get? fun(self:api_conv,idx:string):(unknown)
---@field set? fun(val:unknown,self:api_conv,idx:string)

---Api conversion provider
---@class api_conv
---Overrides that handle the behaviour difference between the apis
---`['*']` is a general handler used for all I/O when defined (replaces api)
---@field private _overrides {['*']:override?, [string]:override|function}
local api_conv = {}

---Add a listener for setting a variable.
---Only reacts to user setting the variable
---@param idx string|'*' name of the variable to listen for getting set ('*' for all)
--- - use `nil` to register for any variable change
---@param cb? fun(val,idx:string):(boolean?) Handler, return true to unregister
--- - pass in `nil` to deregister the hook of given `id`
---@param id string? optional identifier to be able to manually deregister the function
---@return integer|string id
function api_conv.on_set(idx, cb, id) end

--------------------------------------------------------------------------------
-- Main application class
--------------------------------------------------------------------------------

---Main application class.
---@class swi: api_conv
---@field mode appmode_t Which mode is the application in
---@field title string Window title text
---@field antialiasing boolean Enable/disable antialiasing
---Enable or disable window decoration (title, border, buttons).
---Available only in Wayland, the corresponding protocol must be
---supported by the composer.
---By default disabled in Sway and enabled in other compositors.
---@field decoration boolean
---Create a floating window with the same coordinates and size as the currently
---focused window. This variable can be set only once.
---Sway and Hyprland compositors only.
---By default enabled in Sway and disabled in other compositors.
---@field overlay boolean
---Set mouse button used for drag-and-drop image file to external apps. (`MouseRight` etc.)
---Configurable only at startup.
---@field dnd_button string
swi = {}

---Execute a shell command in sync.
---Escape sequences:
--- - `%`: current file unquoted
--- - `%f`: current file quoted with singlequotes
--- - `%s`: all marked files or current file quoted with singlequotes
--- - `%%`: normal percentage sign (`%`)
---@param cmd string
---@return string stdout
function swi.exec(cmd) end

---Exit from application.
---NOTE: exits only if all SwiLeavePre hooks deregister!
---@param code? integer Program exit code, `0` by default
function swi.exit(code) end

---Get mouse pointer coordinates.
---@return { x :integer, y: integer } # Coordinates of the mouse pointer
function swi.get_mouse_pos() end

---Toggle full screen mode.
---@return boolean # True if full screen is enabled
function swi.toggle_fullscreen() end

---Get application window size.
---@return { width: integer, height: integer } # Window size in pixels
function swi.get_window_size() end

---Set application window size.
---@param width integer Width of the window in pixels
---@param height integer Height of the window in pixels
function swi.set_window_size(width, height) end

--- Event loop processing

---@alias event_name_t
---| "ImgChangePre" # just before selecting a different image, data: old image
---| "ImgChange" # after selected image has changed, data: new image
---| "OptionSet" # after setting any option in the api, match: opt object path, data: opt value
---| "ShellCmdPost" # after swi.exec, data: {[cmd],[out]}
---| "ModeChanged" # when mode is changed, match: active mode
---| "WinResized" # when a window is resized, data: new size
---| "SwiEnter" # just after loading config and initializing imagelist
---| "SwiLeavePre" # before exiting swayimg - hooks for given statuscode must deregister to exit
---| "Signal" # USR1 or USR2 received by swayimg
---| "NewHook" # when a hook gets subscribed, match: event, data: hook config
---| "User" # custom user-emitted/triggered signaling

---@class event_cfg
---@field event event_name_t
---@field match? string value the hooks should match against - describes the payload
---@field data any the object in observation

---@class event_state: event_cfg
---@field mode appmode_t
---@field match string match of the pattern

---@class swi.eventloop.subscribe.opts
---@field event event_name_t|event_name_t[]
---@field mode? appmode_t|appmode_t[]
---@field group? string
---Simple string to match directly, luapat,
---or negated simple match ("!plainstr") to forbid that match
---@field pattern? string|string[]
---@field callback fun(state:event_state):(boolean?)

---@alias hook_id table

---@class swi.eventloop.filter.opts
---@field event? event_name_t|event_name_t[]
---@field id? hook_id
---@field group? string|string[]
---@field mode? appmode_t|appmode_t[]
---@field match? string|string[]

---Event loop processor
---@class swi.eventloop
swi.eventloop = {}

---@param f swi.eventloop.filter.opts
function swi.eventloop.unsubscribe(f) end

---@param f? swi.eventloop.filter.opts
---@return swi.eventloop.subscribe.opts[]
function swi.eventloop.get_subscribed(f) end

---@param state event_cfg
function swi.eventloop.trigger(state) end

---@param hook swi.eventloop.subscribe.opts
---@return hook_id id that can be used to remove the hook
function swi.eventloop.subscribe(hook) end

--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

---Image list
---Changes to the contents get emitted as OptionSet(`swi.imagelist.size`)
---@class swi.imagelist: api_conv
---@field order order_t Image list sort order
---@field reverse boolean Reverse the sort order
---@field recursive boolean Recursive directory reading
---@field adjacent boolean Open adjacent files from the same directory
swi.imagelist = {}

---Get current image entry (may or may not have loaded metadata)
---@return swayimg.entry
function swi.imagelist.get_current() end

---Get size of image list.
---@return integer # Number of entries in the image list
function swi.imagelist.size() end

---Get list of all entries in the image list.
---@return swayimg.entry[] # Array with all entries
function swi.imagelist.get() end

---Add entry to the image list.
---@param path string Path to add
---@param silent true? whether to supress emmiting size change event
function swi.imagelist.add(path, silent) end

---Remove entry from the image list.
---@param path string Path to remove
---@param silent true? whether to supress emmiting size change event
function swi.imagelist.remove(path, silent) end

---Helper for working with marks on images
---Changes to the size get emitted as OptionSet(`swi.imagelist.marked.size`)
---@class swi.imagelist.marked
swi.imagelist.marked = {}

---Get number of marked images.
---@return integer
function swi.imagelist.marked.size() end

---Get list of all marked paths.
---@return string[] paths of all marked images
function swi.imagelist.marked.get() end

---Toggle the marked state of the current entry.
---@param state boolean|'toggle'
---@param silent true? whether to supress emmiting size change event
function swi.imagelist.marked.set_current(state, silent) end

--------------------------------------------------------------------------------
-- Text overlay layer
--------------------------------------------------------------------------------

---Text overlay layer.
---@class swi.text: api_conv
---Should displaying the text layer be allowed,
---and how long for (after switching to a different image).
---Use `true` to disable timeout and permanently display, `false` to always hide, x for x seconds
---@field enabled boolean|number
---@field font string Font face name
---@field size integer Font size in pixels
---@field line_spacing number Factor of amount of space between lines (>0)
---@field padding integer Padding from window edges in pixels
---@field foreground integer Foreground text color in ARGB format, e.g. `0xff00aa99`
---@field background integer Background text color in ARGB format, e.g. `0xff00aa99`
---@field shadow integer Shadow text color in ARGB format, e.g. `0xff00aa99`
---@field status_timeout number Timeout in seconds after which the status message is hidden
swi.text = {}

---Get immediate visibility state of the text layer.
---@return boolean visible
function swi.text.is_visible() end

---Show status message for the duration of `swi.text.status_timeout` seconds.
---@param status string Status text to show
function swi.text.set_status(status) end

--------------------------------------------------------------------------------
-- Base mode class
--------------------------------------------------------------------------------

---@class mode_base.text: api_conv
---@field topleft text_template_t[] Text layer scheme for top-left corner
---@field topright text_template_t[] Text layer scheme for top-right corner
---@field bottomleft text_template_t[] Text layer scheme for bottom-left corner
---@field bottomright text_template_t[] Text layer scheme for bottom-right corner

---Base class providing text overlay layout fields shared by all display modes.
---@class mode_base: api_conv
---@field text mode_base.text access to setting the overlay fields/indexes
---@field mark_color integer Mark icon color in ARGB format
local mode_base = {}

---Remove all existing key/mouse/signal bindings.
function mode_base.bind_reset() end

---Map a keyboard or mouse event to an action.
---@param bind string 1 or more mouse or keyboard events to map - `Alt+s`, etc.
---@param fn fun() callback function to run
---@param desc string? optional description of the action
function mode_base.map(bind, fn, desc) end

---@class mapping_cfg
---@field fn function the action that runs on the binding activation
---@field src string where was the binding defined
---@field desc? string optional description of the action

---@return table<string,mapping_cfg>
function mode_base.get_mapped() end

--------------------------------------------------------------------------------
-- Viewer mode
--------------------------------------------------------------------------------

---Configuration for the grid pattern to be displayed for transparent image bg.
---@class checkerboard
---@field [1] integer first color (i.e. 0xff000000)
---@field [2] integer second color (i.e. 0xff888888)
---@field size integer size of individual grids in pixels

---@alias one_time_scale_t
---| "optimal" # 100% or less to fit to window
---| "width"   # Fit image width to window width
---| "height"  # Fit image height to window height
---| "fit"     # Fit to window
---| "fill"    # Crop image to fill the window

---@alias default_scale_t
---| one_time_scale_t
---| "real"    # Real size (100%)
---| "keep"    # Keep the same scale as for previously viewed image
---| "keep_by_width"  # keep zoom level relative to image width
---| "keep_by_height" # keep zoom level relative to image height
---| "keep_by_size"   # keep zoom level relative to image overall size

---@class swi.viewer.step Move around the image with ready-to-map functions
---@field default_size integer Default size of the step to make (in pixels)
---@field by fun(x:integer,y:integer) Pan the image by x and y pixels in their directions
---@field left fun(p:integer?) Step left by `p` px (default: step.default_size)
---@field right fun(p:integer?) Step right by `p` px (default: step.default_size)
---@field down fun(p:integer?) Step down by `p` px (default: step.default_size)
---@field up fun(p:integer?) Step up by `p` px (default: step.default_size)

---@class swi.viewer : mode_base
---Helper table for easier mappings for switching between images
---@see swi.viewer.switch_image Equivalent via passing a parameter
---@field step swi.viewer.step Helper table for easier mappings for moving around the image
---Helper table for easier mappings for switching between images
---@see swi.viewer.switch_image Equivalent via passing a parameter
---@field go {[vdir_t]:function}
---@field default_scale default_scale_t Default scale applied to newly opened images
---@field scale one_time_scale_t|number Scale of the image as a preset or absolute value
---@field default_position fixed_position_t Default position applied to newly opened images
---Position of the image relative to the position of the window.
---This is the viewport approach!
---Example: ←↑ corner of the image is outside the window -> `x,y<0`
---@field position fixed_position_t|{x:integer,y:integer}
---@field window_background integer|bkgmode_t Window background: solid ARGB color or fill mode
---Background color or pattern for transparent images (ARGB)
---@field image_background integer|checkerboard
---@field loop boolean Image list loop mode
---@field preload_limit integer Number of images to preload in a separate thread
---@field history_limit integer Number of previously viewed images to keep in cache
swi.viewer = {}

do
	---Open the next file in the specified direction.
	---@see swi.viewer.go equivalent using named methods for easier mapping
	---@param dir vdir_t Next file direction
	function swi.viewer.switch_image(dir) end

	---Get information about currently displayed image.
	---@return swayimg.image # Currently displayed image
	function swi.viewer.get_image() end

	---Set absolute image scale, scaling the change around a zoom center.
	---@param scale number Absolute value (1.0 = 100%)
	---@param x integer X coordinate of center point, empty for window center
	---@param y integer Y coordinate of center point, empty for window center
	function swi.viewer.scale_centered(scale, x, y) end

	---Get absolute image scale that the image is currently displayed at.
	---@return number
	function swi.viewer.get_abs_scale() end

	---Reset position and scale to default values.
	---@see swayimg.viewer.set_default_scale
	---@see swayimg.viewer.set_default_position
	function swi.viewer.reset() end

	---Show next frame from multi-frame image (animation).
	---This function stops the animation.
	---@return integer # Index of the currently shown frame
	function swi.viewer.next_frame() end

	---Show previous frame from multi-frame image (animation).
	---This function stops the animation.
	---@return integer # Index of the currently shown frame
	function swi.viewer.prev_frame() end

	---Stop animation.
	function swi.viewer.animation_stop() end

	---Resume animation.
	function swi.viewer.animation_resume() end

	---Flip image vertically.
	function swi.viewer.flip_vertical() end

	---Flip image horizontally.
	function swi.viewer.flip_horizontal() end

	---Rotate image.
	---@param angle rotation_t Rotation angle
	function swi.viewer.rotate(angle) end

	---Export currently displayed frame to PNG file.
	---@param path string Path to the file
	function swi.viewer.export(path) end

	---Add/replace/remove meta info for currently displayed image.
	---@param key string Meta key name
	---@param value string Meta value, empty value to remove the record
	function swi.viewer.set_meta(key, value) end
end

--------------------------------------------------------------------------------
-- Slide show mode
--------------------------------------------------------------------------------

---@class swi.slideshow : swi.viewer
---@field timeout number Timeout in seconds after which the next image is opened
swi.slideshow = {}

--------------------------------------------------------------------------------
-- Gallery mode
--------------------------------------------------------------------------------

---@class swi.gallery : mode_base
---Helper table for easier mappings for switching between images
---@see swi.gallery.switch_image Equivalent via passing a parameter
---@field go {[gdir_t]:function}
---@field aspect aspect_t Thumbnail aspect ratio
---@field thumb_size integer Thumbnail size in pixels
---@field padding_size integer Padding between thumbnails in pixels
---@field border_size integer Border size for the selected thumbnail in pixels
---@field border_color integer Border color for the selected thumbnail in ARGB format
---@field selected_scale number Scale factor for the selected thumbnail (1.0 = 100%)
---@field selected_color integer Background color for the selected thumbnail in ARGB format
---@field unselected_color integer Background color for unselected thumbnails in ARGB format
---@field window_color integer Window background color in ARGB format
---@field cache_limit integer Max number of thumbnails stored in memory cache
---@field preload boolean Preload invisible thumbnails
---@field pstore boolean Persistent storage for thumbnails
---@field pstore_path string Custom path to the directory for persistent thumbnail storage
swi.gallery = {}

---Select the next thumbnail from the gallery.
---@see swi.gallery.go equivalent using named methods for easier mapping
---@param dir gdir_t Next thumbnail direction
function swi.gallery.switch_image(dir) end

---Get information about currently selected image.
---@return swayimg.entry # Currently selected image entry
function swi.gallery.get_image() end
