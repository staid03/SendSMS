;Best viewed in Notepad++ with the AHK syntax file installed.
;This file runs through AutoHotkey a highly versatile freeware scripting program.
;
; AutoHotkey Version: 1.1.29.1
; Language:       English
; Platform:       Windows 10
; Author:         staid03
; Version   Date        Author       Comments
;     0.1   09-JUN-18   staid03      Initial
;
;
; Script Function:
;    GUI for sending text messages at work to staff
;
;functionality to add:
; null

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

GlobalVariables:
myMobile = myMobile


Main:
gui, color, 0EAA99
gui , font , s12
gui , add , text , x12 y12 , To Recipient:
gui , add , edit , x245 y10 w400 vToRecipient
gui , font , s8 italic
gui , add , text , x245 y40, Separate numbers and addresses by semi-colon `;
gui , font , s12 normal
gui , add , text , x12 y67 , CC Recipient:
gui , add , edit , x245 y65 w400 vCCRecipient , %myMobile%
gui , add , text , x12 y117 , Email Subject (not seen in SMS):
gui , add , edit , x245 y115 w400 vEmailSubject , Ticket:  Password Change
gui , add , text , x12 y167 , Email Body (SMS):
gui , add , edit , x245 y165 w400 vEmailBody , Your password has been changed to:  Regards, IT Support
gui , font , s16
gui , add , button , , Send SMS
gui , show
return

buttonSendSMS:
{
	gui , submit , nohide
	ToRecipientFinal := makeRecipientString(ToRecipient)
	CCRecipientFinal := makeRecipientString(CCRecipient)
	
	run , mailto:%ToRecipientFinal%?cc=%CCRecipientFinal%&subject=%EmailSubject%&body=%EmailBody%	
}
return 

makeRecipientString(recipientInput)
{
	;function variables
	SMSService = @smsservice.net
	
	recipientInputStringLength := StrLen(recipientInput)
	ifless , recipientInputStringLength , 10
	{
		msg = The overall string is too short to be meaningful
		errorMSG(msg)
	}

	;check if there is a tailing semi-colon entered and remove it if there is
	stringright , semicolonCheck , recipientInput , 1
	ifequal , semicolonCheck , `;
	{
		stringtrimright , recipientInput , recipientInput , 1
	}
	
	;separate each recipient by semi-colon so that mobile phone numbers can be correctly added
	stringsplit , a , recipientInput , `;
	loop , %a0%
	{
		recipient := a%a_index%
		
		stringreplace , recipient , recipient , %a_space% ,, A
		
		;make sure recipient is at minimum 10 digits long
		recipientStringLength := StrLen(recipient)
		ifless , recipientStringLength , 10
		{
			msg = String length of %recipient% is less than 10 chars long and will not be included - too short for mobile or email addresses
			errorMSG(msg)
		}
		
		;check if mobile number or email address
		ifequal , recipientStringLength , 10
		{		
			;check the first character is a 0 or not
			stringleft , mobileNumberCheck , recipient , 1
			ifnotequal , mobileNumberCheck , 0
			{
				msg = %recipient% is not a valid mobile number
				errorMSG(msg)	
			}
			thisRecipient = %recipient%%SMSService%
		}
		else
		{
			;verify there is an @ symbol in the email address
			ifnotinstring , recipient , @
			{
				msg = %recipient% is not a valid email address (or mobile number)
				errorMSG(msg)				
			}
			thisRecipient = %recipient%
		}		
		
		ifequal , a_index , 1
		{
			recipientList = %thisRecipient%
		}
		else 
		{
			recipientList = %recipientList%`;%thisRecipient%
		}		
	}	
	return recipientList
}



errorMSG(msg)
{
	msgbox ,,,%msg% `n`n----------------------Script ending here!----------------------
	exit
	return
}
return



