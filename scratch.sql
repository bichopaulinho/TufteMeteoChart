
select * from aemet_ftp.aemet_maestro_observatorios limit 3;

select * from aemet_ftp.aemet_maestro_observatorios where nombre ilike '%salamanca%';



select max(fecha_obs), min(fecha_obs) from aemet_ftp.obs_aemet_web_resudia limit 2;

select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_web_resudia where codigo in (select codigo from aemet_ftp.aemet_maestro_observatorios where nombre ilike '%salamanca%')
order by fecha_obs desc limit 100;

select * from aemet_ftp.obs_aemet_series limit 2;
select min(fecha_obs), max(fecha_obs) from aemet_ftp.obs_aemet_series;



select min(fecha_obs) from

(
select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_web_resudia where codigo = 19308
UNION
select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_resudia where codigo = 19308
UNION
select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_series where codigo = 19308

order by fecha_obs desc
)sc1
;
