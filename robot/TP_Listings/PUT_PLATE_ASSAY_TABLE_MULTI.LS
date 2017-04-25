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
                File Name: /MD/PUT_PLATE_ASSAY_TABLE_MULTI.LS<br>
                Date:  17/04/25
                Time: 11:09:52
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  PUT_PLATE_ASSAY_TABLE_MULTI
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 1106;
CREATE		= DATE 15-05-05  TIME 15:04:08;
MODIFIED	= DATE 15-10-27  TIME 19:17:20;
FILE_NAME	= PUT_PLAT;
VERSION		= 0;
LINE_COUNT	= 61;
MEMORY_SIZE	= 1494;
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
   3:  R[1:running]=1    ;
   4:   ;
   5:  !put plate on assay ;
   6:  IF R[5:z_plate]=1,JMP LBL[1] ;
   7:  IF R[5:z_plate]=2,JMP LBL[2] ;
   8:  IF R[5:z_plate]=3,JMP LBL[3] ;
   9:  IF R[5:z_plate]=4,JMP LBL[4] ;
  10:   ;
  11:  LBL[1] ;
  12:  PR[8:next_pos]=PR[17:ASSAY POS1]    ;
  13:  JMP LBL[5] ;
  14:   ;
  15:  LBL[2] ;
  16:  PR[8:next_pos]=PR[18:ASSAY POS2]    ;
  17:  JMP LBL[5] ;
  18:   ;
  19:  LBL[3] ;
  20:  PR[8:next_pos]=PR[19:ASSAY POS3]    ;
  21:  JMP LBL[5] ;
  22:   ;
  23:  LBL[4] ;
  24:  PR[8:next_pos]=PR[20:ASSAY POS4]    ;
  25:   ;
  26:  LBL[5] ;
  27:  FOR R[4:loop_counter1]=1 TO 3 ;
  28:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  29:  ENDFOR ;
  30:  PR[8:next_pos]=PR[8:next_pos]+PR[22:ASSAY_OFFSET_X]    ;
  31:   ;
  32:L PR[8:next_pos] 4000mm/sec CNT100    ;
  33:  PR[8:next_pos]=PR[8:next_pos]-PR[22:ASSAY_OFFSET_X]    ;
  34:L PR[8:next_pos] 4000mm/sec CNT100    ;
  35:   ;
  36:  FOR R[4:loop_counter1]=1 TO 3 ;
  37:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  38:  ENDFOR ;
  39:L PR[8:next_pos] 100mm/sec FINE    ;
  40:   ;
  41:  DO[1:vac. pump]=OFF ;
  42:  WAIT    .50(sec) ;
  43:   ;
  44:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  45:   ;
  46:L PR[8:next_pos] 100mm/sec FINE    ;
  47:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  48:   ;
  49:L PR[8:next_pos] 100mm/sec FINE    ;
  50:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  51:   ;
  52:L PR[8:next_pos] 100mm/sec FINE    ;
  53:   ;
  54:   ;
  55:   ;
  56:  PR[8:next_pos]=PR[8:next_pos]+PR[22:ASSAY_OFFSET_X]    ;
  57:L PR[8:next_pos] 4000mm/sec CNT100    ;
  58:   ;
  59:   ;
  60:J PR[11:above table] 100% CNT100    ;
  61:  R[1:running]=0    ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

