# Changelog

Alle nennenswerten Änderungen an diesem Projekt werden in dieser Datei dokumentiert.
Format orientiert an [Keep a Changelog](https://keepachangelog.com/de/), Versionierung an [SemVer](https://semver.org).

## [0.1.0] – Erstes Starterprojekt

### Hinzugefügt
- **Fliege (Spielcharakter):** 2D-Top-Down-Steuerung (WASD/Pfeiltasten) mit Schweben-Physik, Sprint mit verbrauchender Ausdauer (Regeneration nur beim Ruhen), Flügel-Flatter-Animation und Kamera-Follow mit Zoom.
- **Testlevel:** Ein Raum mit Mittelwand und Tür, Startpunkt oben links, Ziel-Fenster oben rechts (Sieg per Trigger mit Meldung), automatischer Neustart nach Tod (1 s) oder Sieg (2 s), manueller Neustart mit `R`.
- **Patrol-NPC:** Läuft ein wiederholendes Wegpunkt-Muster mit Pausen und sichtbarem Richtungswechsel – Muster-Beobachtung als Kern-Mechanik.
- **Gefahren-Tür:** Zyklus offen → orange Blink-Vorwarnung → zu; blockiert geschlossen den Durchgang und zerquetscht Fliegen, die beim Zuschappen im Türrahmen stehen.
- **Lüftung:** Regelmäßiger Blas-Rhythmus (~2.8 s Pause / ~1.6 s Gust); während des Gusts werden Fliegen im Windkegel weggedrückt (`apply_wind`), der Gust wird visuell eingeblendet.
- **Spinne (Jägerin):** Pendelnder Sichtkegel (SCAN), Alarm-Erstarrfenster beim Entdecken (ALARM, 0,45 s Reaktions Chance), Verfolgung der zuletzt gesehenen Position (JAGD) mit Aufgeben und Rückkehr (RÜCKKEHR); Fang-Kreis tötet die Fliege.
- **HUD:** Ausdauer-Balken (per `stamina_changed`-Signal), Ziel-Meldung, Steuerungshinweise.
- **Wiederverwendbare Wand-Szene:** Größe per Export-Variable, Geometrie wird im Code erzeugt.
- **Projektgerüst:** `project.godot` mit deutscher Input-Map und Fenstergröße 1152×648, SVG-Icon, `.gitignore`, README mit Python↔Godot-Einstiegshilfen.

### Technik
- Godot 4.x, reines GDScript, keine externen Abhängigkeiten oder Assets (alle Grafiken sind code-erzeugte Polygone).
- Alle Scripts durch `gdparse`/`gdlint` (gdtoolkit) ohne Fehler und Warnungen.
