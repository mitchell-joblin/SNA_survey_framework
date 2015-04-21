<?php
//Connect to sql db
$host = "127.0.0.1";
$user = "codeface";
$pass = "codeface";
$db   = "survey";
$db_con = mysqli_connect($host, $user, $pass, $db);
//Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MYSQL: " . mysqli_connect_error();
}

// Extract form data from post message
$respondent_id = (int)$_POST["respondent_id"];
$respondent_name = $_POST["respondent_name"];
$respondent_email = $_POST["respondent_email"];

$q1 = (int)$_POST["q1"];
$q4 = $_POST["q4"];
$q6a = $_POST["q6a"];
$q6b = $_POST["q6b"];
$q7a = $_POST["q7a"];
$q7b = $_POST["q7b"];
$fb  = $_POST["additional_comments"];

// Developer roles
$write_code = (int)array_key_exists('role_1', $_POST);
$test_code = (int)array_key_exists('role_2', $_POST);
$review_code = (int)array_key_exists('role_3', $_POST);
$design = (int)array_key_exists('role_4', $_POST);
$maintenance = (int)array_key_exists('role_5', $_POST);
$fix_defects = (int)array_key_exists('role_6', $_POST);
$steer_dir = (int)array_key_exists('role_7', $_POST);
$other_role =(int)array_key_exists('role_8', $_POST);
$other_text = $_POST["role_other_text"];

$return_email = $_POST["return_email"];
$cluster_id = (int)$_POST["cluster_id"];
$proj_name = $_POST["project_name"];
$proj_id = (int)$_POST["project_id"];
$proj_version = $_POST["project_version"];
$idx_error = (int)$_POST["index_error"];

// Insert form data into database
$response = "INSERT INTO responses_main (respondentId, respondentName, respondentEmail,
              q1, q4, q6a, q6b, q7a, q7b, feedback, writeCode, testCode, reviewCode, design, maintenance, 
              fixDefects, steerOverallDir, otherRole, otherRoleText, responseEmail, 
              clusterId, projectName, projectId, projectVersion, indexError) 
            VALUES ('$respondent_id', '$respondent_name', '$respondent_email', '$q1', 
              '$q4', '$q6a', '$q6b', '$q7a', '$q7b', '$fb', '$write_code',
              '$test_code', '$review_code', '$design', '$maintenance', '$fix_defects',
              '$steer_dir', '$other_role', '$other_text', '$return_email', '$cluster_id',
              '$proj_name', '$proj_id', '$proj_version', '$idx_error')";

// Submit to database
$insert_result = mysqli_query($db_con, $response);
$responseId = mysqli_insert_id($db_con); //do not move this statement!, it needs to be directly after the insert to table "responses_main"

//Question 5 response
for ($i = 1; $i <= 10; $i++) {
  // Get dev id and response from post message
  $dev_id_str = 'dev_id_' . $i;
  $dev_name_str = 'dev_name_' . $i;
  $dev_resp_str = 'dev_' . $i;
  $dev_id = (int)$_POST[$dev_id_str];
  $dev_name = $_POST[$dev_name_str];
  $dev_resp = $_POST[$dev_resp_str];

  // Insert into database
  $response_q5 = "INSERT INTO responses_q5 (responseId, devId, devName, response)
                 VALUES ('$responseId', '$dev_id', '$dev_name', '$dev_resp')";

  mysqli_query($db_con, $response_q5);

}

// Question 2 Response
$q2_keys = preg_grep('/^q2_group_[\d]$/', array_keys($_POST));
foreach($q2_keys as $key) {
  $dev_name = $_POST[$key];

  //Get relationship strength
  $rel_strength_key = $key . "_s";
  $rel_strength= $_POST[$rel_strength_key];

  //Get comment text
  $comment_key = $key . "_comm";
  $comment = $_POST[$comment_key];

  //Get Relationship type
  $rel_type_keys = preg_grep('/^'.$key.'_r_[\d]$/', array_keys($_POST));
  $rel_type = "";
  foreach($rel_type_keys as $r_key) {
    $rel_type .= $_POST[$r_key] . "|";
  }

  $response_q2 = "INSERT INTO responses_q2 (responseId, devName, relationshipStrength, relationshipType, comment)
                 VALUES ('$responseId', '$dev_name', '$rel_strength', '$rel_type', '$comment')";

  mysqli_query($db_con, $response_q2);
}

// Question 3 Response
$q3_keys = preg_grep('/^q3_group_[\d]*/', array_keys($_POST));
foreach($q3_keys as $key) {
  $dev_name = $_POST[$key];
  $response_q3 = "INSERT INTO responses_q3 (responseId, devName)
                 VALUES ('$responseId', '$dev_name')";

  mysqli_query($db_con, $response_q3);
}

$q7_c_keys = preg_grep('/^q7_group_c_[\d]*/', array_keys($_POST));
foreach($q7_c_keys as $key) {
  $dev_name = $_POST[$key];
  $response_q7_c = "INSERT INTO responses_q7_c (responseId, devName)
                 VALUES ('$responseId', '$dev_name')";

  mysqli_query($db_con, $response_q7_c);
}

$q7_d_keys = preg_grep('/^q7_group_d_[\d]*/', array_keys($_POST));
foreach($q7_d_keys as $key) {
  $dev_name = $_POST[$key];
  $response_q7_d = "INSERT INTO responses_q7_d (responseId, devName)
                 VALUES ('$responseId', '$dev_name')";

  mysqli_query($db_con, $response_q7_d);
}


// Close database connection
mysqli_close($db_con);

// Strip form data of problematic characters
function post_process($data) {
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

//go to thank you page
header("Location: thankyou.html")
?>