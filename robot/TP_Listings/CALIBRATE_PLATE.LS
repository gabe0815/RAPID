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
                File Name: /MD/CALIBRATE_PLATE.LS<br>
                Date:  17/04/25
                Time: 11:08:52
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  CALIBRATE_PLATE
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 634;
CREATE		= DATE 14-05-23  TIME 16:29:50;
MODIFIED	= DATE 15-11-02  TIME 11:50:06;
FILE_NAME	= PUT_PLAT;
VERSION		= 0;
LINE_COUNT	= 28;
MEMORY_SIZE	= 894;
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
   1:  UFRAME_NUM=1 ;
   2:  UTOOL_NUM=4 ;
   3:  //R[1:running]=1    ;
   4:   ;
   5:J PR[11:above table] 100% CNT100    ;
   6:   ;
   7:  PR[8:next_pos]=PR[14:calibrate plate]    ;
   8:  FOR R[4:loop_counter1]=1 TO 8 ;
   9:  PR[8:next_pos]=PR[8:next_pos]+PR[7:z_offset]    ;
  10:  ENDFOR ;
  11:   ;
  12:J PR[8:next_pos] 100% CNT20    ;
  13:  PR[8:next_pos]=PR[14:calibrate plate]+PR[7:z_offset]    ;
  14:L PR[8:next_pos] 4000mm/sec FINE    ;
  15:   ;
  16:  DO[1:vac. pump]=OFF ;
  17:  WAIT    .50(sec) ;
  18:L PR[14:calibrate plate] 100mm/sec FINE    ;
  19:  DO[1:vac. pump]=ON ;
  20:  WAIT   1.00(sec) ;
  21:L PR[8:next_pos] 1000mm/sec FINE    ;
  22:  PR[8:next_pos]=PR[14:calibrate plate]    ;
  23:  FOR R[4:loop_counter1]=1 TO 6 ;
  24:  PR[8:next_pos]=PR[8:next_pos]+PR[7:z_offset]    ;
  25:  ENDFOR ;
  26:L PR[8:next_pos] 4000mm/sec FINE    ;
  27:J PR[11:above table] 100% FINE    ;
  28:  //R[1:running]=0    ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

