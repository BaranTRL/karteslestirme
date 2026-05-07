# Gereksinim Analizi Dokümanı

## 1. Amaç

Bu dokümanın amacı, “Kart Eşleştirme” mobil uygulamasının işlevsel ve işlevsel olmayan gereksinimlerini tanımlamak ve proje teslim kısıtlarına uyumu belgelemektir.

## 2. Kapsam

Uygulama, kullanıcıya kartları açıp aynı sembolleri eşleştirme mantığı ile oyun oynatır. Oyun; farklı zorluk seviyeleri ve kullanıcı tarafından girilebilen (JSON) özel ayar ile çalıştırılabilir.

## 3. Paydaşlar

- **Son kullanıcı**: Oyunu oynayan kişi
- **Geliştirici/Öğrenci**: Uygulamayı geliştiren ve kod mantığını açıklayabilen kişi

## 4. İşlevsel Gereksinimler

- **FR-01**: Kullanıcı oyun başlatabilmelidir (yeni oyun).
- **FR-02**: Kullanıcı kartlara dokunarak kartları açabilmelidir.
- **FR-03**: İki kart seçildiğinde:
  - Aynı çift ise eşleşmiş olarak işaretlenmelidir.
  - Farklı ise kısa bir süre gösterildikten sonra tekrar kapanmalıdır.
- **FR-04**: Kullanıcı zorluk seviyesi seçebilmelidir (Kolay/Orta/Zor).
- **FR-05**: Kullanıcı JSON formatında özel ayar girebilmelidir.
- **FR-06**: Oyun bittiğinde kullanıcıya başarı mesajı ve hamle sayısı gösterilmelidir.

## 5. İşlevsel Olmayan Gereksinimler

- **NFR-01 (Kod Kalitesi)**: Anlamlı değişken isimleri, fonksiyonel ayrıştırma ve modüler klasör yapısı kullanılmalıdır.
- **NFR-02 (OOP)**: En az 3 sınıf bulunmalı; encapsulation uygulanmalı; kalıtım veya polymorphism açıkça gösterilmelidir.
- **NFR-03 (Hata Yönetimi)**: Kullanıcı girdileri try-catch ile kontrol edilmelidir.
- **NFR-04 (Dosya Boyutu)**: Tek dosyada 1000 satır aşılmamalıdır.

## 6. Varsayımlar ve Kısıtlar

- Proje Flutter ile geliştirilir.
- Flutter’ın giriş noktası gereği `lib/main.dart` korunur; asıl modüler kaynak kod `Src/` altında tutulur.

## 7. Kabul Kriterleri (Özet)

- Oyun temel akışı sorunsuz çalışmalı (eşleşme, kapanma, bitiş).
- Zorluk seçimleri yeni oyun başlatmalı.
- JSON özel ayar hatalı girilirse uygulama çökmeden kullanıcıya hata mesajı göstermeli.

