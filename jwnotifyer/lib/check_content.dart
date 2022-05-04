class Fetcher {

  String _initial = "NN";

  // Continue listing
  final Map<String,String> _link = {
    "Français":"FR",
    "Español":"ES",
    "English":"EN",
    "Italiano":"IT",
    "Nederlands":"ND"
  };

  set setInitial(String newInitial){
    _initial = newInitial;
  }

  Fetcher({required String language}){
    _initial = _link[language] ?? "NN";
    (language == "None") ? getLinks() : fetchElements();
  }

  Fetcher.getLinks() : this(language: "None");

  Map<String,String> getLinks(){
    return _link;
  }

  DateTime? fetchElements(){
    Map newContent = getNewElement() ?? {"status":"ERROR"};
    return (thereIsNewContent(newContent) ? makeNotification() : null);
  }

  /*

  {
    "initial":"EN",
    "status":"OK"
    "content":[
      {
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      }
    ]
  }

  */


  Map? getNewElement(){
    if(_initial != "NN"){  
      Map test = {};
      return test;
    }
    return null;
  }

  bool thereIsNewContent(newContent){
    // Check si la langue était déjà dans le fichier et si pas il enregistre le nouveau contenu
    // Check que le status soit OK
    // Regarde si le dernier élément de newContent est déjà dans le fichier sauvegardé et etc
    // Enregistre le dernier contenu
    return true;
  }

  DateTime makeNotification(){
    // Make notif + retour d'un DateTime.now()
    return DateTime.now();
  }
}

// TO DO :
// Utiliser le link pour avoir la liste des langues centralisée