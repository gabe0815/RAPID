EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "RAPID phototransistor motor switch"
Date "2017-04-07"
Rev "1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L VCC #PWR?
U 1 1 58E743FB
P 8300 4950
F 0 "#PWR?" H 8300 4800 50  0001 C CNN
F 1 "VCC" H 8300 5100 50  0000 C CNN
F 2 "" H 8300 4950 50  0000 C CNN
F 3 "" H 8300 4950 50  0000 C CNN
	1    8300 4950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 58E7440F
P 9250 5950
F 0 "#PWR?" H 9250 5700 50  0001 C CNN
F 1 "GND" H 9250 5800 50  0000 C CNN
F 2 "" H 9250 5950 50  0000 C CNN
F 3 "" H 9250 5950 50  0000 C CNN
	1    9250 5950
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 58E7442C
P 9250 5550
F 0 "R1" V 9330 5550 50  0000 C CNN
F 1 "10k" V 9250 5550 50  0000 C CNN
F 2 "" V 9180 5550 50  0000 C CNN
F 3 "" H 9250 5550 50  0000 C CNN
	1    9250 5550
	-1   0    0    1   
$EndComp
$Comp
L BC517 Q2
U 1 1 58E74489
P 9250 5050
F 0 "Q2" V 9550 5050 50  0000 L CNN
F 1 "BC517" V 9450 4900 50  0000 L CNN
F 2 "TO-92" V 9650 4600 50  0001 L CIN
F 3 "" H 9250 5050 50  0000 L CNN
	1    9250 5050
	0    -1   -1   0   
$EndComp
$Comp
L CONN_01X02 P1
U 1 1 58E746CB
P 8750 4750
F 0 "P1" H 8750 4900 50  0000 C CNN
F 1 "vibration motor" V 8850 4750 50  0000 C CNN
F 2 "" H 8750 4750 50  0000 C CNN
F 3 "" H 8750 4750 50  0000 C CNN
	1    8750 4750
	0    -1   -1   0   
$EndComp
$Comp
L OPTO_NPN Q1
U 1 1 58E74795
P 8500 5400
F 0 "Q1" V 8650 5400 50  0000 L CNN
F 1 "phototransistor" V 8350 5150 50  0000 L CNN
F 2 "" H 8500 5400 50  0000 C CNN
F 3 "" H 8500 5400 50  0000 C CNN
	1    8500 5400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8300 4950 8700 4950
Wire Wire Line
	8800 4950 9050 4950
Wire Wire Line
	9450 4950 9450 5750
Connection ~ 8300 4950
Wire Wire Line
	8300 4950 8300 5300
Wire Wire Line
	8700 5300 9250 5300
Wire Wire Line
	9250 5250 9250 5400
Connection ~ 9250 5300
Connection ~ 9250 5750
Wire Wire Line
	9250 5700 9250 5950
Wire Wire Line
	9250 5750 9450 5750
$EndSCHEMATC
