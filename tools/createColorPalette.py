import numpy as np
import matplotlib.pyplot as plt
from scipy.special import comb

def bezier(t, control_points):
    n = len(control_points) - 1
    result = np.zeros(3)
    for i, point in enumerate(control_points):
        result += comb(n, i) * (1 - t)**(n - i) * t**i * np.array(point)
    return result

def create_color_palette(start_color, middle_color, end_color, num_steps):
    color_palette = []
    for i in range(num_steps):
        t = i / (num_steps - 1)
        bezier_t = bezier(t, [start_color, middle_color, end_color])
        r = int(bezier_t[0])
        g = int(bezier_t[1])
        b = int(bezier_t[2])
        color_palette.append((i, r, g, b))
    return color_palette

# Anfangs-, Mittel- und Endfarben von Benutzer eingeben (von 0 bis 63)
start_color = [
    int(input("R-Wert der Anfangsfarbe (0-63): ")),
    int(input("G-Wert der Anfangsfarbe (0-63): ")),
    int(input("B-Wert der Anfangsfarbe (0-63): "))
]

middle_color = [
    int(input("R-Wert der Mittelfarbe (0-63): ")),
    int(input("G-Wert der Mittelfarbe (0-63): ")),
    int(input("B-Wert der Mittelfarbe (0-63): "))
]

end_color = [
    int(input("R-Wert der Endfarbe (0-63): ")),
    int(input("G-Wert der Endfarbe (0-63): ")),
    int(input("B-Wert der Endfarbe (0-63): "))
]

# Anzahl der Schritte festlegen
num_steps = 128

# Farbpalette erstellen
palette = create_color_palette(start_color, middle_color, end_color, num_steps)

# Dateinamen für die Ausgabe festlegen
file_name = input("Geben Sie den Dateinamen für die Farbpalette ein: ")

# Die Farbpalette im gewünschten Format in die Datei schreiben
with open(file_name, 'w') as file:
    for entry in palette:
        index, r, g, b = entry
        file.write(f"{index}, {r} {g} {b};\n")

print(f"Die Farbpalette wurde in die Datei {file_name} geschrieben.")
