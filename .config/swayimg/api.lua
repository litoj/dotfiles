---@meta swi

---Api conversion provider
---@class api_conv
---@field private _overrides (function|{get?:fun(self:api_conv):(unknown),set?:fun(val)})[]
local api_conv = {}

---Add a listener for setting a variable.
---Only reacts to user setting the variable
---@param idx string? name of the variable to listen for getting set
--- - use `nil` to register for any variable change
---@param cb fun(val,idx:string):(boolean?) Handler, return true to unregister
function api_conv.on_set(idx, cb) end

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

---Exit from application.
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

---Add a callback function called when main window is resized.
---@param cb fun():(boolean?) Handler, return true to unregister
function swi.on_window_resize(cb) end

---Add a callback function called when all subsystems have been initialized.
---@param cb fun():(boolean?) Handler, return true to unregister
function swi.on_initialized(cb) end

--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

---Image list
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
function swi.imagelist.add(path) end

---Remove entry from the image list.
---@param path string Path to remove
function swi.imagelist.remove(path) end

---Helper for working with marks on images
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
---@param silent true? should the change call no hooks
function swi.imagelist.marked.set_current(state, silent) end

---Register a hook for changes in the number of marked images
---@param cb fun(mark_count:integer):(boolean?) Handler, return true to unregister
function swi.imagelist.marked.on_change(cb) end

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

---Base class providing text overlay layout fields shared by all display modes.
---@class mode_base: swayimg_appmode, api_conv
---@field text_tl text_template_t[] Text layer scheme for top-left corner
---@field text_tr text_template_t[] Text layer scheme for top-right corner
---@field text_bl text_template_t[] Text layer scheme for bottom-left corner
---@field text_br text_template_t[] Text layer scheme for bottom-right corner
---@field mark_color integer Mark icon color in ARGB format
local mode_base = {}

---Map a keyboard or mouse event to an action.
---@param bind string 1 or more mouse or keyboard events to map - `Alt+s`, etc.
---@param cb fun() callback function to run
function mode_base.map(bind, cb) end

---Bind the signal event to a handler.
---@param signal string Signal name (`USR1`, `USR2`, etc.)
---@param cb fun():(boolean?) Handler, return true to unregister
function mode_base.on_signal(signal, cb) end

--------------------------------------------------------------------------------
-- Viewer mode
--------------------------------------------------------------------------------

---Configuration for the grid pattern to be displayed for transparent image bg.
---@class checkerboard
---@field [1] integer first color (i.e. 0xff000000)
---@field [2] integer second color (i.e. 0xff888888)
---@field size integer size of individual grids in pixels

---@class swi.viewer : mode_base
---@field default_scale fixed_scale_t Default scale applied to newly opened images
---@field scale fixed_scale_t|number Scale of the image as a preset or absolute value
---@field default_position fixed_position_t Default position applied to newly opened images
---Position of the image relative to the position of the window.
---Example: ←↑ corner of the image is outside the window -> `x,y<0`
---@field position fixed_position_t|{x:integer,y:integer}
---@field window_background integer|bkgmode_t Window background: solid ARGB color or fill mode
---Background color or pattern for transparent images (ARGB)
---@field image_background integer|checkerboard
---@field freemove boolean Free move mode TODO: needs a more detailed explanation
---@field loop boolean Image list loop mode
---@field preload_limit integer Number of images to preload in a separate thread
---@field history_limit integer Number of previously viewed images to keep in cache
swi.viewer = {}

---Set absolute image scale, scaling the change around a zoom center.
---@param scale number Absolute value (1.0 = 100%)
---@param x integer X coordinate of center point, empty for window center
---@param y integer Y coordinate of center point, empty for window center
function swi.viewer.scale_centered(scale, x, y) end

---Get absolute image scale that the image is currently displayed at.
---@return number
function swi.viewer.get_abs_scale() end

---Open the next file in the specified direction.
---@param dir vdir_t Next file direction
function swi.viewer.switch_image(dir) end

---Get information about currently displayed image.
---@return swayimg.image # Currently displayed image
function swi.viewer.get_image() end

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
---@param dir gdir_t Next thumbnail direction
function swi.gallery.switch_image(dir) end

---Get information about currently selected image.
---@return swayimg.entry # Currently selected image entry
function swi.gallery.get_image() end
