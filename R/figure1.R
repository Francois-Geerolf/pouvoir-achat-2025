# Figure 1 : pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété,
# base 100 en 2019 ; 2026 : prévision de l'Insee (septembre 2026).
# Zone grise : crise inflationniste (2021-2023) ; zone bleue : reflux des dividendes (2024-2025).

library(ggplot2)
library(scales)

source("R/donnees.R")
source("R/prevision2026.R")

series <- rbind(donnees[donnees$annee >= 2019, c("annee", "pa_officiel", "pa_hors_propriete")],
                prevision_2026(donnees))
series$officiel <- 100 * series$pa_officiel / series$pa_officiel[series$annee == 2019]
series$hors <- 100 * series$pa_hors_propriete / series$pa_hors_propriete[series$annee == 2019]

long <- rbind(data.frame(annee = series$annee, indice = series$officiel, Mesure = "Mesure officielle"),
              data.frame(annee = series$annee, indice = series$hors, Mesure = "Hors revenus de la propriété"))
bas <- 0.995 * min(long$indice); haut <- 1.005 * max(long$indice)
long$Mesure <- factor(long$Mesure, levels = c("Mesure officielle", "Hors revenus de la propriété"))

# Ce que montre chaque mesure sur les deux épisodes
val <- function(s, x) sqrt(s[series$annee == floor(x)] * s[series$annee == ceiling(x)])
etiquettes <- data.frame(
  x = c(2022, 2022, 2024.5, 2024.5),
  y = c(val(series$officiel, 2022) * 1.004, val(series$hors, 2022) / 1.004,
        val(series$officiel, 2024.5) / 1.004, val(series$hors, 2024.5) / 1.004),
  label = c("stabilité", "baisse", "baisse", "hausse"),
  Mesure = factor(c("Mesure officielle", "Hors revenus de la propriété")[c(1, 2, 1, 2)],
                  levels = levels(long$Mesure)),
  vjust = c(0, 1, 1, 1))

p <- ggplot(long) + theme_minimal() + xlab("") + ylab("") +
  annotate("rect", xmin = 2021, xmax = 2023, ymin = bas, ymax = haut, fill = "grey90") +
  annotate("text", x = 2022, y = bas * 1.002, label = "crise inflationniste", size = 3, colour = "grey40", vjust = 0) +
  annotate("rect", xmin = 2024, xmax = 2025, ymin = bas, ymax = haut, fill = "#dbe7f5") +
  annotate("text", x = 2024.5, y = bas * 1.002, label = "reflux des\ndividendes", size = 3, colour = "grey40", vjust = 0) +
  geom_line(data = long[long$annee <= 2025, ], aes(x = annee, y = indice, colour = Mesure), linewidth = 1) +
  geom_line(data = long[long$annee >= 2025, ], aes(x = annee, y = indice, colour = Mesure),
            linewidth = 1, linetype = "dashed") +
  geom_point(data = long[long$annee == 2026, ], aes(x = annee, y = indice, colour = Mesure), size = 2) +
  geom_text(data = long[long$annee == 2026, ],
            aes(x = annee, y = indice, colour = Mesure, label = format(round(indice, 1), decimal.mark = ",")),
            hjust = -0.3, size = 3.5, show.legend = FALSE) +
  geom_text(data = etiquettes, aes(x = x, y = y, label = label, colour = Mesure, vjust = vjust),
            fontface = "bold", size = 3.5, show.legend = FALSE) +
  scale_colour_manual(values = c("#2a78d6", "#eb6834")) +
  scale_x_continuous(breaks = 2019:2026, limits = c(2019, 2026.5)) +
  scale_y_log10(breaks = seq(90, 120, 1), expand = c(0, 0)) +
  theme(legend.title = element_blank(), legend.position = c(0.25, 0.9), plot.caption = element_text(hjust = 0),
        panel.grid.minor = element_blank()) +
  labs(caption = "Note : base 100 en 2019 ; 2026 : prévision de l'Insee (pointillés).\nSources : Insee, comptes nationaux annuels (base 2020) et note de conjoncture de septembre 2026 ; Eurostat ; calculs de l'auteur.")

ggsave("png/figure1.png", plot = p, width = 1.25 * 6, height = 1.25 * 3.375, bg = "white", dpi = 150)
ggsave("pdf/figure1.pdf", plot = p, width = 1.25 * 6, height = 1.25 * 3.375, dpi = 150)
