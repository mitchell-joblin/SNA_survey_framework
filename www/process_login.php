<?php session_start();

include_once $_SERVER['DOCUMENT_ROOT'] . '/securimage/securimage.php';

$securimage = new Securimage();

if ($securimage->check($_POST['captcha_code']) == false) {
  // the code was incorrect
  // you should handle the error so that the form processor doesn't continue

  // or you can use the following code if there is no validation or you do not know how
  echo "The security code entered was incorrect.<br /><br />";
  echo "Please go <a class='btn btn-primary' type='button' href='login.html'>back</a> and try again.";
  exit;
} else {
  $numApps = 1;
  $srvNum = (string) rand(1,$numApps);
  $app = ":80/survey_" . $srvNum;
  $fname = (empty($_POST['fname'])) ? "[first name]" : $_POST['fname'];
  $lname = (empty($_POST['lname'])) ? "[last name]" : $_POST['lname'];
  $project = (empty($_POST['project'])) ? "[project]" : $_POST['project'];
  $revision = (empty($_POST['revision'])) ? "[revision]" : $_POST['revision'];

  $srv = "http://rfhinf067.hs-regensburg.de" . $app;
  $params = "/?f.name=" . $fname . "&l.name=" . $lname . "&project=" . $project . "&revision=" . $revision;
  $url = $srv . $params;
  header("Location: $url");
  exit;
}
?>
