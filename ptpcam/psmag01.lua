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
  press("shoot_half")
  set_aflock(1)
  set_aelock(1) --NOTE: set_aelock blocks the shooting function shoot(), user press("shoot_half"), press("shoot_full") instead.
  sleep(200)
  print("photo mode ready")
end  

function takeShots(duration)
  startTime=get_tick_count()
  durationTime=duration*1000
  while ((durationTime + startTime) > get_tick_count()) do
    --shoot()
    press("shoot_half")
    press("shoot_full")
    release("shoot_full")

  end
end

function vibrate_s(seconds)
    set_led(9,1)
    sleep(seconds*1000-500)
    set_led(9,0)
    sleep(500)
end

mode_photo()
takeShots(30)
vibrate_s(5)
takeShots(30)
set_aflock(0)
set_aelock(0)
