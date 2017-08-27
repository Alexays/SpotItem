const String version = '0.0.2';
const String clientSecret = 'et+nWhUB>.Dg[c4z';
const String apiUrl = 'http://217.182.65.67:1337/api';
const String apiImgUrl = 'http://217.182.65.67:1337/img/';
const String staticApiKey = 'AIzaSyAJh3ASTwUBo06fQai_PZJa-R9czeRC2D0';
Map<String, String> getHeaders([String key = 'Basic $clientSecret']) =>
    {'Authorization': key, 'accept-version': version};
