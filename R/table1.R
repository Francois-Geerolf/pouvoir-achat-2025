# Tableau 1 : pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété,
# évolutions annuelles en %, 2019-2026 (2026 : prévision de l'Insee, septembre 2026).

library(gt)

source("R/donnees.R")
source("R/prevision2026.R")

series <- rbind(donnees[, c("annee", "pa_officiel", "pa_hors_propriete")], prevision_2026(donnees))
croissance <- function(x) 100 * (x / c(NA, x[-length(x)]) - 1)
series$officiel <- croissance(series$pa_officiel)
series$hors <- croissance(series$pa_hors_propriete)

# Contrôle : la mesure officielle recalculée coïncide avec celle publiée par l'Insee
controle <- merge(series, donnees[, c("annee", "pa_uc_officiel")])
stopifnot(all(abs(controle$officiel - controle$pa_uc_officiel)[controle$annee >= 2000] < 0.05))

t1 <- series[series$annee >= 2019, c("annee", "officiel", "hors")]
t1[, -1] <- round(t1[, -1], 1)   # évite un « -0,0 % » pour 2023
print(t1)

table1 <- data.frame(Mesure = c("Mesure officielle", "Hors revenus de la propriété"),
                     rbind(t1$officiel, t1$hors) / 100 + 0)
names(table1)[-1] <- c(as.character(2019:2025), "2026 (prévision)")

table1 <- table1 |>
  gt() |>
  fmt_percent(columns = -1, decimals = 1, force_sign = TRUE, dec_mark = ",") |>
  cols_align(align = "center", columns = -1) |>
  tab_source_note("Sources : Insee, comptes nationaux annuels (base 2020) et note de conjoncture de septembre 2026 ; Eurostat ; calculs de l'auteur.")

gtsave(table1, filename = "png/table1.png")
gtsave(table1, filename = "pdf/table1.pdf")
