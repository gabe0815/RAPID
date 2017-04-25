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
                File Name: /MD/P_TO_T.LS<br>
                Date:  17/04/25
                Time: 11:10:18
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  P_TO_T
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 284;
CREATE		= DATE 16-11-18  TIME 17:48:34;
MODIFIED	= DATE 16-11-18  TIME 17:53:56;
FILE_NAME	= P_TO_A;
VERSION		= 0;
LINE_COUNT	= 6;
MEMORY_SIZE	= 648;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  R[11:todo]=0    ;
   2:  R[1:running]=1    ;
   3:  R[6:forward]=1    ;
   4:  CALL GET_PLATE    ;
   5:  CALL PUT_PLATE_TRASH    ;
   6:  R[1:running]=0    ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

