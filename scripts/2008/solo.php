local player = game.Players:CreateLocalPlayer(0)
<br>
game:GetService("Visit")
<br>
game:GetService("RunService"):run()
<br>
player:LoadCharacter()
<?php
  $name = $_GET["name"];
  $ran = strval(rand(0, 9999));
  if ($name == !null) {
    echo "player.Name = "$name"";
  }
  if ($name == "") {
    $name = "NoName $ran";
    echo "player.Name = "$name"";
  }
?>
<br>
-- if you want a username then put "?name=" in the url and put a username
<br>
-- example: http://justgoodgame.tk/Files/scripts/2008+/Play_Solo.php?name=examplename
<br>
-- remember to use http instead of https else it will not work. have fun playing!
