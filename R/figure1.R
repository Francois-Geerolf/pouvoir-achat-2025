# Graphique 1 : pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété,
# base 100 en 2019 ; 2026 : prévision de l'Insee (septembre 2026).
# Zone grise : crise inflationniste (2021-2023) ; zone bleue : reflux des dividendes (2024-2025).
# Version publiée sur le blog de l'IFE-OFCE (25 novembre 2026).

library(ggplot2)

source("R/donnees.R")
source("R/prevision2026.R")

series <- rbind(donnees[donnees$annee >= 2019, c("annee", "pa_officiel", "pa_hors_propriete")],
                prevision_2026(donnees))
annee <- series$annee

pa <- rbind(
  data.frame(annee, indice = 100 * series$pa_officiel / series$pa_officiel[annee == 2019],
             mesure = "Tous revenus"),
  data.frame(annee, indice = 100 * series$pa_hors_propriete / series$pa_hors_propriete[annee == 2019],
             mesure = "Hors revenus de la propriété"))
pa$mesure <- factor(pa$mesure, levels = c("Tous revenus", "Hors revenus de la propriété"))
couleurs <- c("Tous revenus" = "#2a78d6", "Hors revenus de la propriété" = "#eb6834")

# Ce que montre chaque mesure sur les deux épisodes
valeur <- function(m, x) exp(mean(log(pa$indice[pa$mesure == m & pa$annee %in% c(floor(x), ceiling(x))])))
etiquettes <- data.frame(
  x = c(2022, 2022, 2024.5, 2024.5),
  mesure = factor(levels(pa$mesure)[c(1, 2, 1, 2)], levels = levels(pa$mesure)),
  label = c("stabilité", "baisse", "baisse", "hausse"),
  decalage = c(1.004, 1 / 1.004, 1 / 1.004, 1 / 1.004))
etiquettes$y <- mapply(valeur, as.character(etiquettes$mesure), etiquettes$x) * etiquettes$decalage
etiquettes$vjust <- ifelse(etiquettes$decalage > 1, 0, 1)

bas <- 99; haut <- 105.2

p <- ggplot(pa, aes(annee, indice, colour = mesure)) +
  annotate("rect", xmin = 2021, xmax = 2023, ymin = bas, ymax = haut, fill = "#e6e5e0") +
  annotate("rect", xmin = 2024, xmax = 2025, ymin = bas, ymax = haut, fill = "#dbe7f5") +
  annotate("text", x = 2022, y = bas + 0.1, label = "crise inflationniste", vjust = 0, size = 3.2, colour = "#5f5e5a") +
  annotate("text", x = 2024.5, y = bas + 0.1, label = "reflux des\ndividendes", vjust = 0, size = 3.2,
           colour = "#5f5e5a", lineheight = 0.9) +
  geom_line(data = subset(pa, annee <= 2025), linewidth = 1) +
  geom_line(data = subset(pa, annee >= 2025), linewidth = 1, linetype = "22") +
  geom_point(data = subset(pa, annee == 2026), size = 1.8) +
  geom_text(data = subset(pa, annee == 2026), aes(label = format(round(indice, 1), decimal.mark = ",")),
            hjust = -0.3, size = 3.5, colour = "#1f1f1e", show.legend = FALSE) +
  geom_text(data = etiquettes, aes(x = x, y = y, label = label, vjust = vjust),
            fontface = "bold", size = 3.5, show.legend = FALSE) +
  annotate("text", x = 2025.5, y = min(pa$indice[pa$annee == 2026]) - 0.35, label = "2026 : prévision",
           size = 3, colour = "#5f5e5a") +
  scale_colour_manual(values = couleurs) +
  scale_x_continuous(breaks = 2019:2026, limits = c(2019, 2026.6)) +
  scale_y_continuous(breaks = 99:105, limits = c(bas, haut), expand = c(0, 0)) +
  labs(x = NULL, y = "Indice, base 100 en 2019", colour = NULL,
       caption = paste0("Note : taux annuels du tableau 1 cumulés ; 2026, prévision (pointillés).\n",
                        "Sources : Insee, comptes nationaux annuels, base 2020, et note de conjoncture de septembre 2026 ;\n",
                        "Eurostat (nasa_10_nf_tr) ; calculs de l'auteur.")) +
  theme_minimal(base_size = 11) +
  theme(legend.position = c(0.22, 0.92),
        panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        axis.title.y = element_text(colour = "#5f5e5a", size = 10),
        plot.caption = element_text(hjust = 0, colour = "#5f5e5a", size = 8))

# Données du graphique (indices base 100 en 2019)
dir.create("csv", showWarnings = FALSE)
write.csv(data.frame(annee = pa$annee, mesure = pa$mesure, indice = round(pa$indice, 3)),
          "csv/figure1.csv", row.names = FALSE)

ggsave("png/figure1.png", plot = p, width = 8, height = 5, bg = "white", dpi = 150)
ggsave("pdf/figure1.pdf", plot = p, width = 8, height = 5)
