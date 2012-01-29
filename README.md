**RatpBusTime** is a Lua applet for Squeezeplay and other _Squeeze devices_ from Logitech (not the Squeezebox Boom since it doesn't support Lua applets).

It connects to the **RATP** website and fetches bus lines and stations for your to choose the ones you want to track. Once selected, stations are added to your preferences and you can check the time your next two buses arrive directly on the radio screen. So your bus times are always just one click away.

RATP is the Parisian bus and metro network. They still don't provide an API to get this kind of information so it is necessary to parse their wonderful markup.

Please note that I am not affiliated with RATP in anyway and I am not their fan neither (tickets more expensive every year, service always worse).

## How to install (French)

Pour l'installer, le mieux c'est d'utiliser un mac (ou Linux), sauf si tu peux utiliser SSH et SCP sur ton Windows.

En gros, il faut :

- Activer la connexion à distance à ta radio. Ca se trouve dans Paramètres avancés.
- Ensuite, tu peux te logguer à ta radio avec les identifiants :
login: root
pass: 1234

Mais avec SCP, pas besoin de se logguer:

```
 scp -r RatpBusTime root@192.168.?.?:/usr/share/jive/applets/
```

Tu devras remplacer l'adresse IP avec celle de ta radio.
Cette commande permet d'envoyer le répertoire RatpBusTime dans le répertoire des plugins de ta radio.

Ensuite tu peux redémarrer ta radio pour que les modifs soient prises en compte.

## How to install (English)

http://wiki.slimdevices.com/index.php/SqueezePlay_Applets#Manual_installation

## License

The MIT License (MIT)
Copyright © 2012 Bertrand Mansion, http://mansion.im

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

