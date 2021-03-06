
#Ejercicio postwork de la sesi�n 05


#Se define directorio de trabajo en donde est�n los csv con la informaci�n de las tres temporadas

setwd("C:\\Users\\Oscar Salazar\\OneDrive\\Documents\\Data Analyst\\2_R y Py\\Postwork\\postwork2")

#Se leen todos los documentos dentro del directorio
SmallData <- lapply(dir(), read.csv)

library("dplyr")

#Filtrado de columnas con la funci�n select de dplyr
SmallData <- lapply(SmallData, select, Date, HomeTeam:FTAG)

#Formaci�n de un solo data frame
SmallData <- do.call(rbind, SmallData)

View(SmallData)

str(SmallData)

#Formato de fecha para la columna "date"
SmallData <- mutate(SmallData, Date = as.Date(Date, format="%d/%m/%y"))

#Se renombran las columnas para utilizar el paquete fbranks
SmallData <- rename(SmallData, date=Date, home.team=HomeTeam,
                    away.team=AwayTeam, home.score=FTHG, away.score=FTAG)

#Creaci�n del csv "soccer" para utilizarlo en fbranks
write.csv(SmallData, "soccer.csv", row.names = FALSE)

library("fbRanks")

#Se desarrolla una lista con distintos dataframes con la funci�n create.fb...
listasoccer <- create.fbRanks.dataframes("soccer.csv")

#Asignaci�n de dataframes a variables anotaciones y equipos
anotaciones <- listasoccer$scores
equipos <- listasoccer$teams

#Lista de fechas (sin repetidos)
fecha <- unique(SmallData$date)

n <- length(fecha)

#se ordenan las fechas en orden cronol�gico
fecha <- sort(fecha)

#obtenci�n de fecha inicial y pen�ltima fecha
f.inicial <- fecha[1] 
f.penultima <- fecha[length(fecha)-1]

#Utilizaci�n de funci�n "rank.teams" para calificar a cada equipo
#se definieron fecha inicial y final
ranking <- rank.teams(anotaciones, equipos,
                      max.date = f.penultima,
                      min.date = f.inicial)

#se obtienen los �ndices de las filas que contienen la �ltima fecha
partidos.uf <- which(anotaciones$date == fecha[length(fecha)])

#Extracci�n de los partidos realizados en la �ltima fecha
f.ultima <- anotaciones[partidos.uf[1]:partidos.uf[length(partidos.uf)],]

#Predicci�n de los resultados de los partidos de la �ltima fecha
Predicci�n <- predict.fbRanks(ranking, newdata = f.ultima)

#Los resultados generales(gana, pierde, empata) se acertaron en 66%
#En cuanto a los resultados particulares (goles), se acercan las predicciones a los resultados reales.