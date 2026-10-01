// Translations for the extended worked-example catalog.
// Unknown IDs stay null so the caller can handle them explicitly.
String? additionalWorkedExampleTitle(String locale, String id) =>
    _translations[locale]?[id]?.$1;
String? additionalWorkedExampleDescription(String locale, String id) =>
    _translations[locale]?[id]?.$2;

const _translations = <String, Map<String, (String, String)>>{
  'de': {
    "calc1": (
      "Bestimmtes Integral von sin(x)",
      "Fläche unter sin(x) von 0 bis π."
    ),
    "calc2": (
      "Unbestimmtes Integral von e^x",
      "Die Exponentialfunktion integrieren."
    ),
    "calc3": (
      "Ableitung von ln(x)",
      "Die natürliche Logarithmusfunktion ableiten."
    ),
    "calc4": (
      "Ableitung höherer Ordnung",
      "Die zweite Ableitung von x⁴ berechnen."
    ),
    "calc5": (
      "Grenzwert im Unendlichen",
      "Grenzwert von (1 + 1/x)^x für x → ∞."
    ),
    "calc6": ("Regel von L’Hôpital", "Grenzwert von (e^x − 1)/x für x → 0."),
    "calc7": (
      "Taylor-Reihe von cos(x)",
      "Kosinus um 0 bis zur vierten Ordnung entwickeln."
    ),
    "calc8": (
      "Differentialgleichung mit konstanter Ableitung",
      "Die Gleichung y′ = 5 lösen."
    ),
    "calc9": ("Integral einer rationalen Funktion", "1/(x² + 1) integrieren."),
    "calc10": ("Ableitung des Tangens", "tan(x) nach x ableiten."),
    "calc11": (
      "Bestimmtes Integral eines Polynoms",
      "Fläche unter x³ von 1 bis 2."
    ),
    "calc12": (
      "Grenzwert einer rationalen Funktion",
      "Den Grenzwert für x → 2 berechnen."
    ),
    "calc13": ("Produktregel", "x·e^x ableiten."),
    "calc14": ("Quotientenregel", "sin(x)/x ableiten."),
    "calc15": (
      "Integral von ln(x)",
      "Den natürlichen Logarithmus partiell integrieren."
    ),
    "alg1": (
      "Kubische Gleichung lösen",
      "Nullstellen von x³ − 6x² + 11x − 6 = 0."
    ),
    "alg2": ("Binom ausmultiplizieren", "(x + y)⁴ ausmultiplizieren."),
    "alg3": (
      "Differenz zweier Quadrate faktorisieren",
      "x² − 81 faktorisieren."
    ),
    "alg4": (
      "Lineares System mit drei Variablen",
      "Ein Gleichungssystem mit drei Unbekannten lösen."
    ),
    "alg5": (
      "Betragsgleichung lösen",
      "Den Betrag von x − 3 gleich 5 setzen und lösen."
    ),
    "alg6": ("Rationale Gleichung lösen", "1/x + 1/(x + 1) = 5/6 lösen."),
    "alg7": (
      "Doppelbruch vereinfachen",
      "(1/x + 1/y)/(1/x − 1/y) vereinfachen."
    ),
    "alg8": (
      "Quadratische Formel mit symbolischen Koeffizienten",
      "ax² + bx + c = 0 nach x lösen."
    ),
    "alg9": ("Logarithmische Gleichung", "ln(x) = 2 lösen."),
    "alg10": ("Exponentialgleichung", "e^(2x) = 10 lösen."),
    "alg11": ("Polynom faktorisieren", "x⁴ − 1 faktorisieren."),
    "alg12": ("Ungleichung lösen", "2x − 5 < 7 lösen."),
    "alg13": ("Ungleichungssystem", "x + y < 4 und x > 0 lösen."),
    "alg14": (
      "Quadrat eines Trinoms ausmultiplizieren",
      "(x + y + z)² ausmultiplizieren."
    ),
    "alg15": ("Quadratwurzel vereinfachen", "√72 vereinfachen."),
    "alg16": (
      "Nullstellen einer Gleichung vierten Grades",
      "x⁴ − 5x² + 4 = 0 lösen."
    ),
    "alg17": (
      "Durch Gruppieren faktorisieren",
      "x³ + x² + x + 1 faktorisieren."
    ),
    "la1": ("Matrizen addieren", "Zwei 2×2-Matrizen addieren."),
    "la2": (
      "Matrizen multiplizieren",
      "Eine 2×3- mit einer 3×2-Matrix multiplizieren."
    ),
    "la3": (
      "Determinante einer 3×3-Matrix",
      "Die Determinante einer 3×3-Matrix berechnen."
    ),
    "la4": (
      "Inverse einer 2×2-Matrix",
      "Die Inverse einer 2×2-Matrix bestimmen."
    ),
    "la5": ("Spur einer Matrix", "Die Spur einer 3×3-Matrix berechnen."),
    "la6": (
      "Kreuzprodukt",
      "Das Kreuzprodukt zweier dreidimensionaler Vektoren berechnen."
    ),
    "la7": ("Skalarprodukt", "Das Skalarprodukt zweier Vektoren berechnen."),
    "la8": (
      "Matrix transponieren",
      "Die Transponierte einer Matrix bestimmen."
    ),
    "la9": ("Eigenwerte einer 2×2-Matrix", "Die Eigenwerte bestimmen."),
    "la10": ("Matrix quadrieren", "Eine 2×2-Matrix quadrieren."),
    "la11": (
      "Reduzierte Zeilenstufenform",
      "Die reduzierte Zeilenstufenform einer Matrix bestimmen."
    ),
    "la12": (
      "Determinante einer 4×4-Matrix",
      "Die Determinante einer größeren Matrix berechnen."
    ),
    "la13": (
      "Skalarmultiplikation",
      "Eine Matrix mit einem Skalar multiplizieren."
    ),
    "la14": ("Vektoren addieren", "Zwei Vektoren addieren."),
    "la15": ("Vektorbetrag", "Die Länge eines Vektors berechnen."),
    "la16": (
      "Äußeres Produkt",
      "Das äußere Produkt zweier Vektoren berechnen."
    ),
    "nt1": ("Primfaktorzerlegung von 1001", "1001 in Primfaktoren zerlegen."),
    "nt2": ("Größter gemeinsamer Teiler", "Den ggT von 54 und 24 berechnen."),
    "nt3": (
      "Kleinstes gemeinsames Vielfaches",
      "Das kgV von 21 und 6 berechnen."
    ),
    "nt4": ("Modulo-Arithmetik", "Den Rest von 17 geteilt durch 5 berechnen."),
    "nt5": ("Modulare Potenz: 3⁴ mod 5", "3⁴ modulo 5 berechnen."),
    "nt6": ("Primzahltest", "Prüfen, ob 97 eine Primzahl ist."),
    "nt7": ("n-te Primzahl", "Die zehnte Primzahl bestimmen."),
    "nt8": ("Eulersche Phi-Funktion", "φ(36) berechnen."),
    "nt9": ("Binomialkoeffizient", "10 über 3 berechnen."),
    "nt10": ("Fakultät", "7! berechnen."),
    "nt11": ("Teilersumme", "Die Teiler von 28 summieren."),
    "nt12": ("Anzahl der Teiler", "Die Teiler von 100 zählen."),
    "nt13": (
      "Nächste Primzahl",
      "Die kleinste Primzahl größer als 100 bestimmen."
    ),
    "nt14": (
      "Vorherige Primzahl",
      "Die größte Primzahl kleiner als 100 bestimmen."
    ),
    "nt15": ("ggT mehrerer Zahlen", "Den ggT von 30, 45 und 60 berechnen."),
    "nt16": (
      "Quotient und Rest",
      "Den ganzzahligen Quotienten und den Rest bestimmen."
    ),
    "stat1": (
      "Mittelwert einer Liste",
      "Den Mittelwert von 1, 2, 3, 4 und 5 berechnen."
    ),
    "stat2": ("Varianz einer Liste", "Die Populationsvarianz berechnen."),
    "stat3": (
      "Standardabweichung",
      "Die Standardabweichung der Werte berechnen."
    ),
    "stat4": ("Median einer Liste", "Den mittleren Wert bestimmen."),
    "stat5": ("Variationen ohne Wiederholung", "5 P 3 berechnen."),
    "stat6": ("Kombinationen", "5 über 3 berechnen."),
    "stat7": (
      "Dichte der Normalverteilung",
      "Dichte der Standardnormalverteilung bei 0."
    ),
    "stat8": (
      "Verteilungsfunktion der Normalverteilung",
      "Wahrscheinlichkeit X < 0 bei der Standardnormalverteilung."
    ),
    "stat9": (
      "Dichte der Gleichverteilung",
      "Die Dichte einer Gleichverteilung berechnen."
    ),
    "stat10": (
      "Verteilungsfunktion der Exponentialverteilung",
      "Die kumulierte Wahrscheinlichkeit der Exponentialverteilung berechnen."
    ),
    "stat11": (
      "Poisson-Wahrscheinlichkeit",
      "Poisson-Wahrscheinlichkeit für λ = 3 und k = 2."
    ),
    "stat12": (
      "Binomialwahrscheinlichkeit",
      "Binomialwahrscheinlichkeit für n = 10, p = 0,5 und k = 5."
    ),
    "stat13": ("Summe der Elemente", "Die Zahlen einer Liste addieren."),
    "stat14": (
      "Produkt der Elemente",
      "Die Zahlen einer Liste multiplizieren."
    ),
    "stat15": (
      "Maximum der Elemente",
      "Den größten Wert einer Liste bestimmen."
    ),
    "stat16": (
      "Minimum der Elemente",
      "Den kleinsten Wert einer Liste bestimmen."
    ),
    "stat17": ("Kovarianz", "Die Kovarianz zweier Listen berechnen."),
    "unit1": ("Längen umrechnen", "1 Meter in Zoll umrechnen."),
    "unit2": ("Massen umrechnen", "1 Kilogramm in Pfund umrechnen."),
    "unit3": (
      "Temperaturen umrechnen",
      "0 Grad Celsius in Fahrenheit umrechnen."
    ),
    "unit4": ("Geschwindigkeiten umrechnen", "60 mph in km/h umrechnen."),
    "unit5": ("Volumen umrechnen", "1 Gallone in Liter umrechnen."),
    "unit6": ("Energie umrechnen", "1 Joule in Kalorien umrechnen."),
    "unit7": ("Leistung umrechnen", "1 hp in Watt umrechnen."),
    "unit8": ("Druck umrechnen", "1 Atmosphäre in Pascal umrechnen."),
    "unit9": ("Zeit umrechnen", "1 Tag in Sekunden umrechnen."),
    "unit10": ("Flächen umrechnen", "1 Acre in Quadratmeter umrechnen."),
    "unit11": ("Datenspeicher", "1 Gigabyte in Megabyte umrechnen."),
    "unit12": ("Kräfte umrechnen", "1 Newton in Pfund-Kraft umrechnen."),
    "unit13": ("Winkel umrechnen", "180 Grad in Radiant umrechnen."),
    "unit14": (
      "Dichte umrechnen",
      "Die Dichte von Wasser in lb/ft³ umrechnen."
    ),
    "unit15": ("Kraftstoffverbrauch", "30 mpg in L/100 km umrechnen."),
    "unit16": ("Elektrischer Strom", "1 Ampere in Milliampere umrechnen."),
    "unit17": ("Spannung umrechnen", "1 Kilovolt in Volt umrechnen."),
  },
  'fr': {
    "calc1": ("Intégrale définie de sin(x)", "Aire sous sin(x) de 0 à π."),
    "calc2": (
      "Intégrale indéfinie de e^x",
      "Intégrer la fonction exponentielle."
    ),
    "calc3": ("Dérivée de ln(x)", "Dériver le logarithme naturel."),
    "calc4": (
      "Dérivée d’ordre supérieur",
      "Calculer la dérivée seconde de x⁴."
    ),
    "calc5": ("Limite à l’infini", "Limite de (1 + 1/x)^x quand x → ∞."),
    "calc6": ("Règle de l’Hôpital", "Limite de (e^x − 1)/x quand x → 0."),
    "calc7": (
      "Série de Taylor de cos(x)",
      "Développer le cosinus autour de 0 jusqu’à l’ordre 4."
    ),
    "calc8": (
      "Équation différentielle à dérivée constante",
      "Résoudre y′ = 5."
    ),
    "calc9": ("Intégrale d’une fonction rationnelle", "Intégrer 1/(x² + 1)."),
    "calc10": ("Dérivée de la tangente", "Dériver tan(x) par rapport à x."),
    "calc11": ("Intégrale définie d’un polynôme", "Aire sous x³ de 1 à 2."),
    "calc12": (
      "Limite d’une fonction rationnelle",
      "Calculer la limite quand x → 2."
    ),
    "calc13": ("Règle du produit", "Dériver x·e^x."),
    "calc14": ("Règle du quotient", "Dériver sin(x)/x."),
    "calc15": (
      "Intégrale de ln(x)",
      "Intégrer le logarithme naturel par parties."
    ),
    "alg1": (
      "Résoudre une équation cubique",
      "Racines de x³ − 6x² + 11x − 6 = 0."
    ),
    "alg2": ("Développer un binôme", "Développer (x + y)⁴."),
    "alg3": ("Factoriser une différence de carrés", "Factoriser x² − 81."),
    "alg4": (
      "Système linéaire à trois variables",
      "Résoudre un système à trois inconnues."
    ),
    "alg5": (
      "Résoudre une équation avec valeur absolue",
      "Résoudre l’équation où la valeur absolue de x − 3 vaut 5."
    ),
    "alg6": (
      "Résoudre une équation rationnelle",
      "Résoudre 1/x + 1/(x + 1) = 5/6."
    ),
    "alg7": (
      "Simplifier une fraction complexe",
      "Simplifier (1/x + 1/y)/(1/x − 1/y)."
    ),
    "alg8": (
      "Formule quadratique à coefficients symboliques",
      "Résoudre ax² + bx + c = 0 en x."
    ),
    "alg9": ("Équation logarithmique", "Résoudre ln(x) = 2."),
    "alg10": ("Équation exponentielle", "Résoudre e^(2x) = 10."),
    "alg11": ("Factoriser un polynôme", "Factoriser x⁴ − 1."),
    "alg12": ("Résoudre une inéquation", "Résoudre 2x − 5 < 7."),
    "alg13": ("Système d’inéquations", "Résoudre x + y < 4 et x > 0."),
    "alg14": ("Développer le carré d’un trinôme", "Développer (x + y + z)²."),
    "alg15": ("Simplifier une racine carrée", "Simplifier √72."),
    "alg16": (
      "Racines d’une équation du quatrième degré",
      "Résoudre x⁴ − 5x² + 4 = 0."
    ),
    "alg17": ("Factoriser par regroupement", "Factoriser x³ + x² + x + 1."),
    "la1": ("Addition de matrices", "Additionner deux matrices 2×2."),
    "la2": (
      "Multiplication de matrices",
      "Multiplier une matrice 2×3 par une matrice 3×2."
    ),
    "la3": (
      "Déterminant d’une matrice 3×3",
      "Calculer le déterminant d’une matrice 3×3."
    ),
    "la4": (
      "Inverse d’une matrice 2×2",
      "Trouver l’inverse d’une matrice 2×2."
    ),
    "la5": ("Trace d’une matrice", "Calculer la trace d’une matrice 3×3."),
    "la6": (
      "Produit vectoriel",
      "Calculer le produit vectoriel de deux vecteurs en trois dimensions."
    ),
    "la7": (
      "Produit scalaire",
      "Calculer le produit scalaire de deux vecteurs."
    ),
    "la8": ("Transposée d’une matrice", "Transposer une matrice."),
    "la9": (
      "Valeurs propres d’une matrice 2×2",
      "Trouver les valeurs propres."
    ),
    "la10": ("Carré d’une matrice", "Élever une matrice 2×2 au carré."),
    "la11": (
      "Forme échelonnée réduite",
      "Calculer la forme échelonnée réduite d’une matrice."
    ),
    "la12": (
      "Déterminant d’une matrice 4×4",
      "Calculer le déterminant d’une matrice plus grande."
    ),
    "la13": (
      "Multiplication par un scalaire",
      "Multiplier une matrice par un scalaire."
    ),
    "la14": ("Addition de vecteurs", "Additionner deux vecteurs."),
    "la15": ("Norme d’un vecteur", "Calculer la longueur d’un vecteur."),
    "la16": (
      "Produit tensoriel",
      "Calculer le produit tensoriel de deux vecteurs."
    ),
    "nt1": (
      "Décomposition de 1001 en facteurs premiers",
      "Décomposer 1001 en facteurs premiers."
    ),
    "nt2": ("Plus grand commun diviseur", "Calculer le PGCD de 54 et 24."),
    "nt3": ("Plus petit commun multiple", "Calculer le PPCM de 21 et 6."),
    "nt4": (
      "Arithmétique modulaire",
      "Calculer le reste de la division de 17 par 5."
    ),
    "nt5": ("Puissance modulaire : 3⁴ mod 5", "Calculer 3⁴ modulo 5."),
    "nt6": ("Test de primalité", "Vérifier si 97 est premier."),
    "nt7": ("n-ième nombre premier", "Trouver le dixième nombre premier."),
    "nt8": ("Indicatrice d’Euler", "Calculer φ(36)."),
    "nt9": (
      "Coefficient binomial",
      "Calculer le nombre de choix de 3 éléments parmi 10."
    ),
    "nt10": ("Factorielle", "Calculer 7!."),
    "nt11": ("Somme des diviseurs", "Additionner les diviseurs de 28."),
    "nt12": ("Nombre de diviseurs", "Compter les diviseurs de 100."),
    "nt13": (
      "Nombre premier suivant",
      "Trouver le plus petit nombre premier supérieur à 100."
    ),
    "nt14": (
      "Nombre premier précédent",
      "Trouver le plus grand nombre premier inférieur à 100."
    ),
    "nt15": ("PGCD de plusieurs nombres", "Calculer le PGCD de 30, 45 et 60."),
    "nt16": ("Quotient et reste", "Calculer le quotient entier et le reste."),
    "stat1": ("Moyenne d’une liste", "Calculer la moyenne de 1, 2, 3, 4 et 5."),
    "stat2": ("Variance d’une liste", "Calculer la variance de la population."),
    "stat3": ("Écart-type", "Calculer l’écart-type des valeurs."),
    "stat4": ("Médiane d’une liste", "Trouver la valeur centrale."),
    "stat5": ("Arrangements sans répétition", "Calculer 5 P 3."),
    "stat6": (
      "Combinaisons",
      "Calculer le nombre de choix de 3 éléments parmi 5."
    ),
    "stat7": (
      "Densité normale",
      "Densité de la loi normale centrée réduite en 0."
    ),
    "stat8": (
      "Fonction de répartition normale",
      "Probabilité X < 0 pour la loi normale centrée réduite."
    ),
    "stat9": ("Densité uniforme", "Calculer la densité d’une loi uniforme."),
    "stat10": (
      "Fonction de répartition exponentielle",
      "Calculer la probabilité cumulée d’une loi exponentielle."
    ),
    "stat11": (
      "Probabilité de Poisson",
      "Probabilité de Poisson pour λ = 3 et k = 2."
    ),
    "stat12": (
      "Probabilité binomiale",
      "Probabilité binomiale pour n = 10, p = 0,5 et k = 5."
    ),
    "stat13": ("Somme des éléments", "Additionner les nombres d’une liste."),
    "stat14": ("Produit des éléments", "Multiplier les nombres d’une liste."),
    "stat15": (
      "Maximum des éléments",
      "Trouver la plus grande valeur d’une liste."
    ),
    "stat16": (
      "Minimum des éléments",
      "Trouver la plus petite valeur d’une liste."
    ),
    "stat17": ("Covariance", "Calculer la covariance de deux listes."),
    "unit1": ("Conversion de longueur", "Convertir 1 mètre en pouces."),
    "unit2": ("Conversion de masse", "Convertir 1 kilogramme en livres."),
    "unit3": (
      "Conversion de température",
      "Convertir 0 degré Celsius en Fahrenheit."
    ),
    "unit4": ("Conversion de vitesse", "Convertir 60 mph en km/h."),
    "unit5": ("Conversion de volume", "Convertir 1 gallon en litres."),
    "unit6": ("Conversion d’énergie", "Convertir 1 joule en calories."),
    "unit7": ("Conversion de puissance", "Convertir 1 hp en watts."),
    "unit8": ("Conversion de pression", "Convertir 1 atmosphère en pascals."),
    "unit9": ("Conversion de temps", "Convertir 1 jour en secondes."),
    "unit10": ("Conversion de surface", "Convertir 1 acre en mètres carrés."),
    "unit11": ("Stockage de données", "Convertir 1 gigaoctet en mégaoctets."),
    "unit12": ("Conversion de force", "Convertir 1 newton en livres-force."),
    "unit13": ("Conversion d’angle", "Convertir 180 degrés en radians."),
    "unit14": (
      "Conversion de masse volumique",
      "Convertir la masse volumique de l’eau en lb/ft³."
    ),
    "unit15": ("Consommation de carburant", "Convertir 30 mpg en L/100 km."),
    "unit16": ("Courant électrique", "Convertir 1 ampère en milliampères."),
    "unit17": ("Conversion de tension", "Convertir 1 kilovolt en volts."),
  },
  'es': {
    "calc1": ("Integral definida de sin(x)", "Área bajo sin(x) de 0 a π."),
    "calc2": ("Integral indefinida de e^x", "Integrar la función exponencial."),
    "calc3": ("Derivada de ln(x)", "Derivar el logaritmo natural."),
    "calc4": (
      "Derivada de orden superior",
      "Calcular la segunda derivada de x⁴."
    ),
    "calc5": ("Límite en el infinito", "Límite de (1 + 1/x)^x cuando x → ∞."),
    "calc6": ("Regla de L’Hôpital", "Límite de (e^x − 1)/x cuando x → 0."),
    "calc7": (
      "Serie de Taylor de cos(x)",
      "Desarrollar el coseno alrededor de 0 hasta el orden 4."
    ),
    "calc8": (
      "Ecuación diferencial con derivada constante",
      "Resolver y′ = 5."
    ),
    "calc9": ("Integral de una función racional", "Integrar 1/(x² + 1)."),
    "calc10": ("Derivada de la tangente", "Derivar tan(x) respecto a x."),
    "calc11": ("Integral definida de un polinomio", "Área bajo x³ de 1 a 2."),
    "calc12": (
      "Límite de una función racional",
      "Calcular el límite cuando x → 2."
    ),
    "calc13": ("Regla del producto", "Derivar x·e^x."),
    "calc14": ("Regla del cociente", "Derivar sin(x)/x."),
    "calc15": (
      "Integral de ln(x)",
      "Integrar el logaritmo natural por partes."
    ),
    "alg1": (
      "Resolver una ecuación cúbica",
      "Raíces de x³ − 6x² + 11x − 6 = 0."
    ),
    "alg2": ("Desarrollar un binomio", "Desarrollar (x + y)⁴."),
    "alg3": ("Factorizar una diferencia de cuadrados", "Factorizar x² − 81."),
    "alg4": (
      "Sistema lineal de tres variables",
      "Resolver un sistema con tres incógnitas."
    ),
    "alg5": (
      "Resolver una ecuación con valor absoluto",
      "Resolver la ecuación donde el valor absoluto de x − 3 es 5."
    ),
    "alg6": (
      "Resolver una ecuación racional",
      "Resolver 1/x + 1/(x + 1) = 5/6."
    ),
    "alg7": (
      "Simplificar una fracción compleja",
      "Simplificar (1/x + 1/y)/(1/x − 1/y)."
    ),
    "alg8": (
      "Fórmula cuadrática con coeficientes simbólicos",
      "Resolver ax² + bx + c = 0 para x."
    ),
    "alg9": ("Ecuación logarítmica", "Resolver ln(x) = 2."),
    "alg10": ("Ecuación exponencial", "Resolver e^(2x) = 10."),
    "alg11": ("Factorizar un polinomio", "Factorizar x⁴ − 1."),
    "alg12": ("Resolver una inecuación", "Resolver 2x − 5 < 7."),
    "alg13": ("Sistema de inecuaciones", "Resolver x + y < 4 y x > 0."),
    "alg14": (
      "Desarrollar el cuadrado de un trinomio",
      "Desarrollar (x + y + z)²."
    ),
    "alg15": ("Simplificar una raíz cuadrada", "Simplificar √72."),
    "alg16": (
      "Raíces de una ecuación de cuarto grado",
      "Resolver x⁴ − 5x² + 4 = 0."
    ),
    "alg17": ("Factorizar por agrupación", "Factorizar x³ + x² + x + 1."),
    "la1": ("Suma de matrices", "Sumar dos matrices de 2×2."),
    "la2": (
      "Multiplicación de matrices",
      "Multiplicar una matriz de 2×3 por una de 3×2."
    ),
    "la3": (
      "Determinante de una matriz de 3×3",
      "Calcular el determinante de una matriz de 3×3."
    ),
    "la4": (
      "Inversa de una matriz de 2×2",
      "Hallar la inversa de una matriz de 2×2."
    ),
    "la5": ("Traza de una matriz", "Calcular la traza de una matriz de 3×3."),
    "la6": (
      "Producto vectorial",
      "Calcular el producto vectorial de dos vectores tridimensionales."
    ),
    "la7": (
      "Producto escalar",
      "Calcular el producto escalar de dos vectores."
    ),
    "la8": ("Transpuesta de una matriz", "Transponer una matriz."),
    "la9": (
      "Valores propios de una matriz de 2×2",
      "Hallar los valores propios."
    ),
    "la10": ("Cuadrado de una matriz", "Elevar una matriz de 2×2 al cuadrado."),
    "la11": (
      "Forma escalonada reducida",
      "Calcular la forma escalonada reducida de una matriz."
    ),
    "la12": (
      "Determinante de una matriz de 4×4",
      "Calcular el determinante de una matriz mayor."
    ),
    "la13": (
      "Multiplicación por un escalar",
      "Multiplicar una matriz por un escalar."
    ),
    "la14": ("Suma de vectores", "Sumar dos vectores."),
    "la15": ("Magnitud de un vector", "Calcular la longitud de un vector."),
    "la16": (
      "Producto tensorial",
      "Calcular el producto tensorial de dos vectores."
    ),
    "nt1": (
      "Factorización prima de 1001",
      "Descomponer 1001 en factores primos."
    ),
    "nt2": ("Máximo común divisor", "Calcular el MCD de 54 y 24."),
    "nt3": ("Mínimo común múltiplo", "Calcular el MCM de 21 y 6."),
    "nt4": ("Aritmética modular", "Calcular el resto de dividir 17 entre 5."),
    "nt5": ("Potencia modular: 3⁴ mod 5", "Calcular 3⁴ módulo 5."),
    "nt6": ("Prueba de primalidad", "Comprobar si 97 es primo."),
    "nt7": ("n-ésimo número primo", "Hallar el décimo número primo."),
    "nt8": ("Función φ de Euler", "Calcular φ(36)."),
    "nt9": (
      "Coeficiente binomial",
      "Calcular las combinaciones de 10 elementos tomados de 3 en 3."
    ),
    "nt10": ("Factorial", "Calcular 7!."),
    "nt11": ("Suma de divisores", "Sumar los divisores de 28."),
    "nt12": ("Número de divisores", "Contar los divisores de 100."),
    "nt13": (
      "Siguiente número primo",
      "Hallar el menor número primo mayor que 100."
    ),
    "nt14": (
      "Número primo anterior",
      "Hallar el mayor número primo menor que 100."
    ),
    "nt15": ("MCD de varios números", "Calcular el MCD de 30, 45 y 60."),
    "nt16": ("Cociente y resto", "Calcular el cociente entero y el resto."),
    "stat1": ("Media de una lista", "Calcular la media de 1, 2, 3, 4 y 5."),
    "stat2": ("Varianza de una lista", "Calcular la varianza poblacional."),
    "stat3": (
      "Desviación estándar",
      "Calcular la desviación estándar de los valores."
    ),
    "stat4": ("Mediana de una lista", "Hallar el valor central."),
    "stat5": ("Variaciones sin repetición", "Calcular 5 P 3."),
    "stat6": (
      "Combinaciones",
      "Calcular las combinaciones de 5 elementos tomados de 3 en 3."
    ),
    "stat7": (
      "Densidad normal",
      "Densidad de la distribución normal estándar en 0."
    ),
    "stat8": (
      "Función de distribución normal",
      "Probabilidad X < 0 en la distribución normal estándar."
    ),
    "stat9": (
      "Densidad uniforme",
      "Calcular la densidad de una distribución uniforme."
    ),
    "stat10": (
      "Función de distribución exponencial",
      "Calcular la probabilidad acumulada de una distribución exponencial."
    ),
    "stat11": (
      "Probabilidad de Poisson",
      "Probabilidad de Poisson para λ = 3 y k = 2."
    ),
    "stat12": (
      "Probabilidad binomial",
      "Probabilidad binomial para n = 10, p = 0,5 y k = 5."
    ),
    "stat13": ("Suma de elementos", "Sumar los números de una lista."),
    "stat14": (
      "Producto de elementos",
      "Multiplicar los números de una lista."
    ),
    "stat15": (
      "Máximo de los elementos",
      "Hallar el mayor valor de una lista."
    ),
    "stat16": (
      "Mínimo de los elementos",
      "Hallar el menor valor de una lista."
    ),
    "stat17": ("Covarianza", "Calcular la covarianza de dos listas."),
    "unit1": ("Conversión de longitud", "Convertir 1 metro a pulgadas."),
    "unit2": ("Conversión de masa", "Convertir 1 kilogramo a libras."),
    "unit3": (
      "Conversión de temperatura",
      "Convertir 0 grados Celsius a Fahrenheit."
    ),
    "unit4": ("Conversión de velocidad", "Convertir 60 mph a km/h."),
    "unit5": ("Conversión de volumen", "Convertir 1 galón a litros."),
    "unit6": ("Conversión de energía", "Convertir 1 julio a calorías."),
    "unit7": ("Conversión de potencia", "Convertir 1 hp a vatios."),
    "unit8": ("Conversión de presión", "Convertir 1 atmósfera a pascales."),
    "unit9": ("Conversión de tiempo", "Convertir 1 día a segundos."),
    "unit10": ("Conversión de área", "Convertir 1 acre a metros cuadrados."),
    "unit11": ("Almacenamiento de datos", "Convertir 1 gigabyte a megabytes."),
    "unit12": ("Conversión de fuerza", "Convertir 1 newton a libras-fuerza."),
    "unit13": ("Conversión de ángulo", "Convertir 180 grados a radianes."),
    "unit14": (
      "Conversión de densidad",
      "Convertir la densidad del agua a lb/ft³."
    ),
    "unit15": ("Consumo de combustible", "Convertir 30 mpg a L/100 km."),
    "unit16": ("Corriente eléctrica", "Convertir 1 amperio a miliamperios."),
    "unit17": ("Conversión de voltaje", "Convertir 1 kilovoltio a voltios."),
  },
};
