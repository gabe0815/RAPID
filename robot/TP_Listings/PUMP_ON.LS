<html>
<head>
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Cache-Control" content="no-store">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title> ROBOT (robot) Homepage </title>


<script language=javascript>
<!--
var openSetupWin = null;
var openLogWin = null;
var openRuntimeWin = null;
var clientSetupObj = null;

function CenterPopup(URL, width, height) {
  try {
    if (!clientSetupObj) { //not created yet
      clientSetupObj = new ActiveXObject("VisionWebControls.VWCClientSetupObject");
      clientSetupObj.Environment("FANUC_LANG") = "eg";
    }
  }
  catch (err) {
    //ignore errors
  }
  var left = (screen.width-width)/2;
  if (left < 0) {
    left = 0;
  }
  var top = (screen.height-height)/2;
  if (top < 0) {
    top = 0;
  }
  var features='"toolbar=no, location=no, status=no, menubar=no, scrollbars=no, resizable=yes, ' +
      'width=' + width + ', ' +
      'height=' + height + ', ' +
      'top=' + top + ', ' + //
      'left=' + left + '"';
  var popup = window.open(URL, "_blank", features, false);
  if (popup == null) {
    alert("Please enable pop-up windows in Internet Explorer.");
  }
  else {
    popup.focus()
  }
  return popup;
}

////////////////////////////////////////////////////////////////////////////////
// Open Vision Setup
////////////////////////////////////////////////////////////////////////////////
function OpenVisionSetup() {
  try {
    if (openSetupWin && !openSetupWin.closed) {
      // already open
      openSetupWin.focus();
      return;
    }
  } catch (err) {
  }
  var mobj = null;
  try {
    mobj = new ActiveXObject("VisionWebControls.VWCInfo");
  } catch (err) {
    openSetupWin = CenterPopup("/FRH/VISION/VSINST.STM?_page=VSSET.HTM&_vnum=", 1024, 520);
    return;
  }
  openSetupWin = CenterPopup("/FRH/VISION/VSSET.HTM", 1024, 520);
}

////////////////////////////////////////////////////////////////////////////////
// Open Vision Log
////////////////////////////////////////////////////////////////////////////////
function OpenVisionLog() {
  try {
    if (openLogWin && !openLogWin.closed) {
      // already open
      openLogWin.focus();
      return;
    }
  } catch (err) {
  }
  var mobj = null;
  try {
    mobj = new ActiveXObject("VisionWebControls.VWCInfo");
  } catch (err) {
    openLogWin = CenterPopup("/FRH/VISION/VSINST.STM?_page=VLFRMN.STM&_vnum=", 704, 528);
    return;
  }
  openLogWin = CenterPopup("/FRH/VISION/VLFRMN.STM", 704, 528);
}

////////////////////////////////////////////////////////////////////////////////
// Open Vision Runtime
////////////////////////////////////////////////////////////////////////////////
function OpenVisionRuntime() {
  try {
    if (openRuntimeWin && !openRuntimeWin.closed) {
      // already open
      openRuntimeWin.focus();
      return;
    }
  } catch (err) {
  }
  var mobj = null;
  try {
    mobj = new ActiveXObject("VisionWebControls.VWCInfo");
  } catch (err) {
    openRuntimeWin = CenterPopup("/FRH/VISION/VSINST.STM?_page=VREMAN.STM&_vnum=", 704, 400);
    return;
  }
  openRuntimeWin = CenterPopup("/FRH/VISION/VREMAN.STM", 704, 400);
}
//-->
</script>



  <!--COLD START ONLY-->
<!--Jog in Auto Mode -->


</head>
<BODY bgcolor= #FFF9e3>

<table width="100%" border="2">
  <tr>
  <td>
  <table width="100%" bgcolor=#FFFFCC>
  <tr>
  <td align=left valign=middle><img src="/frs/rws_left.png"></td>
  <td align=center valign=middle><strong><font color=#e60000 size=6>
                WEB SERVER</font><br>
        <font color=black size=3>
                Hostname: ROBOT<br>
                Robot No: E38327   <br>
                File Name: /MD/PUMP_ON.LS<br>
                Date:  17/04/25
                Time: 11:09:40
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  PUMP_ON	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 146;
CREATE		= DATE 14-05-21  TIME 09:37:14;
MODIFIED	= DATE 14-05-21  TIME 09:37:30;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 1;
MEMORY_SIZE	= 514;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/MN
   1:  DO[1:vac. pump]=ON ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

