# Modüler Sistem Tasarımı

## Amaç

Kodun okunabilirliğini, sürdürülebilirliğini ve test edilebilirliğini artırmak için kaynak kod **katmanlara ayrılmıştır**.

## Klasörler

### `Src/models/`

- **Sorumluluk**: Veri modelleri (state taşıyan ama UI olmayan sınıflar).
- Örnekler:
  - `GameCard`: kartın durumu (encapsulation ile private alanlar + getter/metotlar)
  - `GameSettings`: oyun ayarları, JSON doğrulama

### `Src/services/`

- **Sorumluluk**: İş kuralları, oyun motoru, yardımcı servisler.
- Örnekler:
  - `GameEngine` (abstract): oyun motoru arayüzü
  - `MemoryGameEngine`: kart eşleştirme oyun motoru (kalıtım)
  - `Shuffler` (abstract) ve `RandomShuffler`: karıştırma stratejisi (polimorfizm)
  - `GameController`: UI ile motor arasındaki köprü (ChangeNotifier)

### `Src/ui/`

- **Sorumluluk**: Sayfalar ve widget’lar.
- Örnekler:
  - `HomePage`: oyun ekranı ve ayar seçimleri
  - `CardTile`: kart bileşeni

### `lib/`

- **Sorumluluk**: Flutter entrypoint. Flutter derleme kuralları nedeniyle uygulama `lib/` içinden import edilir.

Not:

- Proje teslim şartı gereği kaynak kod **`Src/`** altında tutulur.
- Flutter’ın `lib/` odaklı import yapısı için **`lib/Src` bir junction** olarak `Src/` klasörünü işaret eder.

## Bağımlılık Akışı (Özet)

UI → Controller → GameEngine → Models / Services

Bu akış, UI katmanının iş mantığına doğrudan bağımlılığını azaltır ve modülerliği güçlendirir.

