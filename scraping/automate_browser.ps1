. "$($PSScriptRoot)/modules/env.ps1"

function post-jsoncontent($post_uri,$body)
{
  $json = $body | ConvertTo-Json -Compress
  $postBody = [Text.Encoding]::UTF8.GetBytes($json)
  return invoke-restmethod -method post -uri $post_uri -body $postBody -contenttype application/json
}

function get-elmid($uri, $val) {
    $body = @{using="xpath";value=$val}
    $elm_uri = $uri + '/element'
    $rsp = post-jsoncontent $elm_uri $body
    return $rsp.value.ELEMENT
}

function input-form($uri, $dom_id, $content) {
    # get elmid
    $val = '//*[@id="' + $dom_id + '"]'
    $elmid = get-elmid $uri $val

    # clear form
    $body = @{}
    $clear_uri = $uri + '/element/' + $elmid + '/clear'
    $rsp = post-jsoncontent $clear_uri $body

    # input form
    $body = @{value=$content.tochararray()}
    $input_uri = $uri + '/element/' + $elmid + '/value'
    $rsp = post-jsoncontent $input_uri $body
}

function click-button($uri, $dom_id) {
    # get elmid
    $val = '//*[@name="' + $dom_id + '"]'
    $elmid = get-elmid $uri $val

    # click button
    $body = @{}
    $click_uri = $uri + '/element/' + $elmid + '/click'
    $rsp = post-jsoncontent $click_uri $body
}

# start chromedriver
start-process -filepath chromedriver.exe -argumentlist --port=9515

# start browser
$body = @{desiredCapabilities=@{}}
$uri = "http://localhost:9515/session"
$rsp = post-jsoncontent $uri $body

$session_id = $rsp.sessionid
$uri = $uri + '/' + $session_id

# access website
$body = @{url=$URL}
$url_uri = $uri + '/url'
$rsp = post-jsoncontent $url_uri $body

# input forms
input-form $uri $DOM_USERID $USERID
input-form $uri $DOM_PW $PASSWORD
click-button $uri $DOM_LOGIN_BUTTON

# close browser & chromedriver
invoke-restmethod -method delete -Uri $uri
stop-process -id (get-process | where-object { $_.processname -eq "chromedriver" }).id