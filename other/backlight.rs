//Soure code for my backlight control program, rewritten from previous bash version
use std::{
	fs::{self, File},
	io::Write,
};

fn main() {
	match change() {
		Ok(_) => (),
		Err(_) => {
			eprintln!("Please do sudo chown root:root ./backlight && sudo chmod +s ./backlight")
		}
	}
}
fn change() -> Result<(), Box<dyn std::error::Error>> {
	let args: Vec<String> = std::env::args().collect();
	let path = fs::read_dir("/sys/class/backlight")?.next().unwrap()?.path();
	let now_path = path.join("brightness");
	let mut now: u32 = fs::read_to_string(&now_path)?.trim_end().parse()?;
	let max: u32 = fs::read_to_string(path.join("max_brightness"))?.trim_end().parse()?;
	if args.len() > 1 {
		match args[1].as_str() {
			"↓" => now = if now < 2 { 0 } else { now * 2 / 3 - 1 },
			"↑" => {
				now = now * 3 / 2 + 3;
				if now > max {
					now = max
				}
			}
			"-" => {
				let new = args[2].as_str().parse::<u32>()? * max / 100;
				now = if now < new { 0 } else { now - new };
			}
			"+" => {
				let new = args[2].as_str().parse::<u32>()? * max / 100;
				now = if now + new > max { max } else { now + new };
			}
			"=" => {
				now = {
					let new = args[2].as_str().parse::<u32>()? * max / 100;
					if new > max {
						max
					} else {
						new
					}
				};
			}
			_ => (),
		}
		File::create(now_path)?.write_all(now.to_string().as_bytes())?;
	}
	println!("{}", 100 * now / max);
	Ok(())
}
