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
                File Name: /MD/GET_PLATE_ASSAY_TABLE_MULTI.LS<br>
                Date:  17/04/25
                Time: 11:09:20
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  GET_PLATE_ASSAY_TABLE_MULTI
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 1234;
CREATE		= DATE 15-05-05  TIME 15:53:40;
MODIFIED	= DATE 15-10-29  TIME 12:31:44;
FILE_NAME	= GET_PLAT;
VERSION		= 0;
LINE_COUNT	= 62;
MEMORY_SIZE	= 1618;
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
   5:  !get plate from assay ;
   6:   ;
   7:  IF R[5:z_plate]=1,JMP LBL[1] ;
   8:  IF R[5:z_plate]=2,JMP LBL[2] ;
   9:  IF R[5:z_plate]=3,JMP LBL[3] ;
  10:  IF R[5:z_plate]=4,JMP LBL[4] ;
  11:   ;
  12:  LBL[1] ;
  13:  PR[8:next_pos]=PR[17:ASSAY POS1]    ;
  14:  JMP LBL[5] ;
  15:   ;
  16:  LBL[2] ;
  17:  PR[8:next_pos]=PR[18:ASSAY POS2]    ;
  18:  JMP LBL[5] ;
  19:   ;
  20:  LBL[3] ;
  21:  PR[8:next_pos]=PR[19:ASSAY POS3]    ;
  22:  JMP LBL[5] ;
  23:   ;
  24:  LBL[4] ;
  25:  PR[8:next_pos]=PR[20:ASSAY POS4]    ;
  26:  LBL[5] ;
  27:   ;
  28:  FOR R[4:loop_counter1]=1 TO 2 ;
  29:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  30:  ENDFOR ;
  31:  PR[8:next_pos]=PR[8:next_pos]+PR[22:ASSAY_OFFSET_X]    ;
  32:J PR[8:next_pos] 100% CNT50    ;
  33:   ;
  34:   ;
  35:  PR[8:next_pos]=PR[8:next_pos]-PR[22:ASSAY_OFFSET_X]    ;
  36:L PR[8:next_pos] 4000mm/sec FINE    ;
  37:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  38:   ;
  39:  !change counter to calibrate ;
  40:  !activate for loop to calibrate ;
  41:  //FOR R[4:loop_counter1]=1 TO 2 ;
  42:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  43:L PR[8:next_pos] 4000mm/sec FINE    ;
  44:  DO[1:vac. pump]=ON ;
  45:  WAIT   2.00(sec) ;
  46:   ;
  47:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  48:L PR[8:next_pos] 100mm/sec FINE    ;
  49:  !change to match for loop counter ;
  50:  IF R[4:loop_counter1]=2,JMP LBL[6] ;
  51:  DO[1:vac. pump]=OFF ;
  52:  LBL[6] ;
  53:  //ENDFOR ;
  54:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  55:L PR[8:next_pos] 4000mm/sec FINE    ;
  56:  PR[8:next_pos]=PR[8:next_pos]+PR[22:ASSAY_OFFSET_X]    ;
  57:L PR[8:next_pos] 4000mm/sec FINE    ;
  58:   ;
  59:  //L PR[11:above table] 4000mm/sec FINE    ;
  60:   ;
  61:  //R[1:running]=0    ;
  62:  //LBL[*7] ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

