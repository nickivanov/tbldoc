-- 
-- tbldoc_db2v8.sql
--
-- This file is a part of tbldoc v0.1
-- 
-- Copyright (c) 2004-2006 Nick Ivanov / www.datori.org
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. The name of the author may not be used to endorse or promote products
--    derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
-- NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
--
-- This SQL script extracts database catalog information about 
-- table and view columns for use by the tbldoc tool. The output format is
-- an XML file that conforms to the schema defined in tbldoc.xsd
--
-- The SQL in this file is specific to the system catalog of DB2 UDB v.8.1
-- It will probably work with later versions but may not work with earlier
-- versions of DB2.
--
--
echo <?xml version="1.0" encoding="ISO-8859-1"?> ;
echo <?xml-stylesheet type="text/xsl" href="tbldoc.xsl"?> ;
echo <catalog>;

select '<tstamp>',current timestamp,'</tstamp>' from sysibm.sysdummy1 ;
select '<server>',current server,'</server>' from sysibm.sysdummy1 ;

with t0 (fktabschema, fktabname, fkcolname) as (
select distinct k.tabschema, k.tabname, k.colname
from syscat.keycoluse k, syscat.references r
where k.constname=r.constname and k.tabschema=r.tabschema and k.tabname=r.tabname
),
t (schema, table, ttype, column, type, length, scale, dft, nulls, pk, fk, rnum) as (
select c.tabschema, c.tabname, t.type, 
c.colname, c.typename, c.length, c.scale, c.default, c.nulls, 
case when i.uniquerule='P' then 'PK' else '' end as pl,
case when t0.fkcolname is not null then 'FK' else '' end as fk,
row_number() over (partition by c.tabname order by c.colno) as rnum
from 
syscat.columns c
inner join 
syscat.tables t
on c.tabschema=t.tabschema and c.tabname=t.tabname
left outer join
(
syscat.indexcoluse ic
inner join 
syscat.indexes i
on i.indschema = ic.indschema and i.indname=ic.indname and i.uniquerule='P'
)
on c.colname=ic.colname and c.tabschema = i.tabschema and c.tabname=i.tabname

left outer join
t0
on c.colname=t0.fkcolname and c.tabname=t0.fktabname and c.tabschema=t0.fktabschema
--
-- *** Replace search criteria with your own
-- 
where c.tabschema not like 'SYS%' 
-- and c.tabschema = 'SAMPLE'
-- and c.tabname in  ('EMP','DEPT')
order by c.tabschema, c.tabname, c.colno
)
select 
case 
  when rnum = 1 then 
      '<table schema="' concat schema concat '" name="' concat table concat '" type="' concat ttype 
      concat '" typedesc="' concat 
      case 
         when ttype = 'T' then 'Table'
         when ttype = 'V' then 'View'
         when ttype = 'H' then 'Hierarchy'
         when ttype = 'N' then 'Nickname'
         when ttype = 'A' then 'Alias'
         when ttype = 'S' then 'MQT'
         when ttype = 'U' then 'Typed table'
         when ttype = 'W' then 'Typed view'
      end
      concat '">'
  else ''
end as prefix,
'<column name="' concat column concat '" type="' 
concat type concat '" length="' concat char(length) concat '" scale="' 
concat char(scale) concat '" nulls="' concat nulls concat '" default="' 
concat coalesce(dft,'') concat '" key="' concat 
case 
  when pk = '' then fk
  when fk = '' then pk
  else pk concat ',' concat fk
end 
concat '" />',
case
  when rnum = (select max(rnum) from t t2 where t2.schema=t.schema and t2.table=t.table)  then '</table>'
  else ''
end as suffix 

from t
;
echo </catalog>;
