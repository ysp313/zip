# Gestionnaire de Compression JSON

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=for-the-badge&logo=json&logoColor=white)

Une application Flutter intuitive pour compresser et décompresser des données JSON. Cette application simplifie le traitement des données JSON compressées en offrant des fonctionnalités de visualisation, d'édition et de conversion dans les deux sens.

## 🌟 Fonctionnalités

### Onglet Décompresser
- **Décompression instantanée** : Collez votre chaîne compressée et obtenez une visualisation JSON claire
- **Édition interactive** : Modifiez les données JSON décompressées en toute simplicité
- **Export JSON** : Téléchargez les données décompressées au format JSON
- **Recompression** : Transformez votre JSON édité en format compressé et copiez-le dans le presse-papier

### Onglet Compresser
- **Import de fichier** : Chargez vos fichiers JSON existants
- **Édition manuelle** : Collez ou modifiez directement votre JSON
- **Validation intégrée** : Vérifiez que votre JSON est valide avant compression
- **Compression efficace** : Transformez votre JSON en format compressé optimisé
- **Copie facilitée** : Copiez le résultat compressé dans le presse-papier en un clic

## 📱 Captures d'écran

| Décompression | Compression |
|:---:|:---:|
| ![Décompression](https://via.placeholder.com/300x600?text=Onglet+Décompression) | ![Compression](https://via.placeholder.com/300x600?text=Onglet+Compression) |

## 🚀 Installation

1. Assurez-vous d'avoir Flutter installé sur votre machine. Si ce n'est pas le cas, suivez le [guide d'installation Flutter](https://flutter.dev/docs/get-started/install).

2. Clonez ce dépôt :
   ```
   git clone https://github.com/votre-nom/gestionnaire-compression.git
   ```

3. Naviguez vers le répertoire du projet :
   ```
   cd gestionnaire-compression
   ```

4. Installez les dépendances :
   ```
   flutter pub get
   ```

5. Lancez l'application :
   ```
   flutter run
   ```

## 📦 Dépendances

- [archive](https://pub.dev/packages/archive) - Pour les fonctionnalités de compression/décompression
- [file_picker](https://pub.dev/packages/file_picker) - Pour la sélection de fichiers
- [file_saver](https://pub.dev/packages/file_saver) - Pour sauvegarder les fichiers JSON

## 🛠️ Architecture technique

L'application utilise un système de compression/décompression basé sur GZip. Le processus fonctionne ainsi :

1. **Compression** :
    - Conversion de Map JSON en chaîne JSON
    - Encodage de la chaîne en UTF-8
    - Compression des bytes avec GZipEncoder
    - Encodage en format transportable

2. **Décompression** :
    - Décodage du format transportable
    - Décompression avec GZipDecoder
    - Décodage en UTF-8
    - Conversion en Map JSON

### Classe Zipper

```dart
class Zipper {
  const Zipper._();
  
  static String? zip(Map<String, dynamic> json) {
    final jsonStr = jsonEncode(json);
    final bytes = utf8.encode(jsonStr);
    final gzipped = GZipEncoder().encode(bytes);
    if (gzipped == null) return '';
    return jsonEncode(gzipped);
  }

  static Map<String, dynamic>? unzip(String encoded) {
    final bytes = (jsonDecode(encoded) as List).cast<int>();
    final gUnzipped = GZipDecoder().decodeBytes(bytes);
    final jsonStr = utf8.decode(gUnzipped);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

1. Forkez le projet
2. Créez votre branche de fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add some amazing feature'`)
4. Poussez la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📊 Utilisation type

1. **Pour décompresser des données** :
    - Collez les données compressées dans le champ de texte
    - Cliquez sur "Décompresser et afficher"
    - Visualisez ou modifiez les données JSON
    - Téléchargez ou recompressez selon vos besoins

2. **Pour compresser des données** :
    - Chargez un fichier JSON ou collez du JSON
    - Validez le JSON avec le bouton "Valider"
    - Cliquez sur "Compresser"
    - Copiez le résultat compressé

---

Développé avec ❤️ en utilisant Flutter