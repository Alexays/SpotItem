const String keyUser = 'KEY_USER';
const String keyOauthToken = 'KEY_AUTH_TOKEN';
const String keyProvider = 'KEY_AUTH_PROVIDER';
const String version = '0.1.0';
const String clientSecret = 'et+nWhUB>.Dg[c4z';
const String apiUrl = 'http://217.182.65.67:1337/api';
const String apiImgUrl = 'http://217.182.65.67:1337/img/';
const String staticApiKey = 'AIzaSyAJh3ASTwUBo06fQai_PZJa-R9czeRC2D0';
List<String> providers = ['google', 'local'];
Map<String, String> getHeaders([String key]) => {
      'Authorization': key,
      'spotkey': 'Basic $clientSecret',
      'accept-version': version
    };
