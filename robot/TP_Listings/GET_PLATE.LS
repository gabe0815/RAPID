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
                File Name: /MD/GET_PLATE.LS<br>
                Date:  17/04/25
                Time: 11:09:08
        </font></strong></td>
  <td align=right valign=middle><img src="/frs/rws_rght.png"></td>
  </tr>
  </table>
  </td>
  </tr>
</table>
<PRE>
<XMP>
/PROG  GET_PLATE
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 1188;
CREATE		= DATE 14-05-21  TIME 17:25:20;
MODIFIED	= DATE 15-12-06  TIME 17:31:30;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 68;
MEMORY_SIZE	= 1676;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/MN
   1:  UFRAME_NUM=1 ;
   2:  UTOOL_NUM=4 ;
   3:  R[1:running]=1    ;
   4:  //R[2:x_plate]=1    ;
   5:  //R[3:y_plate]=1    ;
   6:  //R[5:z_plate]=1    ;
   7:  R[4:loop_counter1]=1    ;
   8:   ;
   9:J PR[23:ABOVE_PICKUP] 100% CNT100    ;
  10:  !get plate at x.y.z ;
  11:  PR[8:next_pos]=PR[5:pickup_table]    ;
  12:   ;
  13:  IF R[2:x_plate]=1,JMP LBL[4] ;
  14:  FOR R[4:loop_counter1]=2 TO R[2:x_plate] ;
  15:  PR[8:next_pos]=PR[8:next_pos]+PR[9:x_offset]    ;
  16:  ENDFOR ;
  17:   ;
  18:  LBL[4] ;
  19:  IF R[3:y_plate]=1,JMP LBL[5] ;
  20:   ;
  21:   ;
  22:  FOR R[4:loop_counter1]=2 TO R[3:y_plate] ;
  23:  PR[8:next_pos]=PR[8:next_pos]+PR[10:y_offset]    ;
  24:  ENDFOR ;
  25:   ;
  26:  LBL[5] ;
  27:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  28:  FOR R[4:loop_counter1]=1 TO R[12:num_layers] ;
  29:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  30:  ENDFOR ;
  31:L PR[8:next_pos] 4000mm/sec FINE    ;
  32:   ;
  33:   ;
  34:  //IF R[5:z_plate]=R[12:num_layers],JMP LBL[1] ;
  35:   ;
  36:   ;
  37:  FOR R[4:loop_counter1]=R[5:z_plate] TO R[12:num_layers] ;
  38:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  39:  ENDFOR ;
  40:   ;
  41:   ;
  42:   ;
  43:  LBL[1] ;
  44:  PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  45:   ;
  46:L PR[8:next_pos] 300mm/sec FINE    ;
  47:  IF R[6:forward]=0,JMP LBL[2] ;
  48:  DO[1:vac. pump]=ON ;
  49:  JMP LBL[3] ;
  50:  LBL[2] ;
  51:  DO[1:vac. pump]=OFF ;
  52:  //PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  53:  //L PR[8:next_pos] 300mm/sec FINE    ;
  54:  //PR[8:next_pos]=PR[8:next_pos]-PR[15:plate_thickness]    ;
  55:  //L PR[8:next_pos] 50mm/sec FINE    ;
  56:   ;
  57:  LBL[3] ;
  58:  WAIT   2.00(sec) ;
  59:   ;
  60:   ;
  61:  FOR R[4:loop_counter1]=R[5:z_plate] TO R[12:num_layers] ;
  62:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  63:  ENDFOR ;
  64:   ;
  65:  PR[8:next_pos]=PR[8:next_pos]+PR[15:plate_thickness]    ;
  66:L PR[8:next_pos] 1000mm/sec FINE    ;
  67:J PR[11:above table] 100% CNT100    ;
  68:  R[1:running]=0    ;
/POS
/END

</XMP></PRE>
</BODY>
</HTML>

