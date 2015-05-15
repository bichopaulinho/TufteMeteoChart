# En primera versión, saco datasets de la db de Obervaciones

library(meteologica)

GetEstaciones <- function(ciudad){
    est <- EjecutarQuery(sql = sprintf("select * from aemet_ftp.aemet_maestro_observatorios where nombre ilike '%%%s%%';", ciudad),
                         host = 'db.gregal.intranet.meteologica.com', 
                         dbname = 'observaciones', 
                         user = 'observaciones')
    if (nrow(est)==0){
        warning("No hay estaciones\n")
    }
    return(est)
}
    
 
GetTempData <- function(cod_est){
    
    return(EjecutarQuery(sql=sprintf("select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_web_resudia where codigo = %d UNION
                         select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_resudia where codigo = %d
                         UNION
                         select codigo, fecha_obs, tempmax, tempmin, tempmed from aemet_ftp.obs_aemet_series where codigo = %d
                         order by fecha_obs desc", cod_est, cod_est, cod_est),
           host = 'db.gregal.intranet.meteologica.com', 
           dbname = 'observaciones', 
           user = 'observaciones'))
    
}  

datos <- lapply(c(19308, 19309), GetTempData)
names(datos) <- paste0("EST", c(19308, 19309))

saveRDS(datos, file='data/salamanca.rds')
