capmode=require("capmode")
props=require("propcase")
myFocus=2759


function mode_photo()
  switch_mode_usb(1)
  sleep(1000)
  capmode.set(capmode.name_to_mode["PHOTO_STD"])
  sleep(3000)
  set_zoom(6)
  sleep(3000)
  set_prop(props.FLASH_MODE,2) -- turn off flash
  sleep(100)
  set_nd_filter(2) -- nd filter out ( 0=auto, 1=in, 2=out )
  set_aflock(1)
  set_aelock(1) --NOTE: set_aelock blocks the shooting function shoot(), user press("shoot_half"), press("shoot_full") instead.
  sleep(200)
  print("photo mode ready")
end  

mode_photo()
