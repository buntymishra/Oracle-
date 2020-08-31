
--use of limit close 
set SERVEROUTPUT ON
DECLARE
type plt_objs is table of TEMP_OBJECT%rowtype;
ins_objs plt_objs;
CURSOR crs_objs is select * from TEMP_OBJECT; 
lv_stime number;
lv_total number:=0;
BEGIN
lv_stime := dbms_utility.get_time;
open crs_objs;
loop
fetch crs_objs BULK COLLECT into ins_objs limit 30000;
exit when ins_objs.count=0;
lv_total:= lv_total+ins_objs.count;
--dbms_output.put_line('Total load : '||ins_objs.count||' total time '||(dbms_utility.Get_Time- lv_stime));
end loop;
close crs_objs;
dbms_output.put_line('Total load : '||lv_total||' total time '||(dbms_utility.Get_Time- lv_stime));
end;

------------------------------------------
--use of limit,exception & and forall in package
set echo on
set serveroutput on
set time on
set timing on
set define off

spool./log /<file-name>.log

create or replace package <pkg-name>/PKG_DM_AGX_AGT
IS

	PROCEDURE PROC_DM_AGX_ACTIVE_SUBSTANCE;
	PROCEDURE PROC_DM_AGX_ACTIVITY_LOG;
	PROCEDURE PROC_DM_AGX_DEVICE;
END PKG_DM_AGX_AGT;
/
SHOW ERRORS;


CREATE OR REPLACE PACKAGE BODY PKG_DM_AGX_AGT
IS
PROCEDURE PROC_DM_AGX_ACTIVE_SUBSTANCE 
IS 
	CURSOR C1 IS
		SELECT RECORD_ID,FK_AD_REC_ID,VERSION,USER_MODIFIED,DATE_MODIFIED,MESSAGE_STATE
		FROM S_AGX_ACTIVE_SUBSTANCE
		WHERE MESSAGE_STATE IN(2,4,102,105,90)
		AND RECORD_ID NOT IN(SELECT RECORD_ID FROM AGX_ACTIVE_SUBSTANCE);
TYPE AA_COLL IS TABLE OF C1%ROWTYPE;
AGX_COLL AA_COLL;
L_STATUS VARCHAR2(30);
BEGIN
	OPEN C1;
	LOOP
		FETCH C1 BULK COLLECT INTO AGX_COLL LIMIT 50000;
		EXIT 
		WHEN AGX_COLL.COUNT=0;
		BEGIN
			FORALL I IN 1..AGX_COLL.COUNT SAVE EXCEPTIONS
			INSERT INTO AGX_ACTIVE_SUBSTANCE(RECORD_ID,FK_AD_REC_ID,VERSION,USER_MODIFIED,DATE_MODIFIED,MESSAGE_STATE)
			VALUES(AGX_COLL(I).RECORD_ID,
					AGX_COLL(I).FK_AD_REC_ID,
					AGX_COLL(I).VERSION,
					AGX_COLL(I).USER_MODIFIED,
					SYSDATE,
					AGX_COLL(I).MESSAGE_STATE);
			EXCEPTION
			WHEN OTHERS THEN 
				L_STATUS	:='FAIL';
				L_ERRORS	:=SQL%BULK_EXCEPTIONS.COUNT;
				FOR I IN 1..L_ERRORS
				LOOP
					L_ERRNO :=SQL%BULK_EXCEPTIONS
					(I).ERRORS_CODE;
					L_MSG	:=SQLERRM(-L_ERRNO);
					L_IDX	:=SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;
				END LOOP;
					


set echo off
set serveroutput off
set time off
set timing off
set define off


























