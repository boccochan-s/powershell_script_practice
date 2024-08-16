new-item -itemtype directory -name "chromedriver" -force
remove-item "./chromedriver/*"

$current_chrome_ver = (get-childitem -path "C:\Program Files\Google\Chrome\Application" | where-object { $_.name -match "\d{3}" }).name

$uri = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
$chrome_info_list = (invoke-webrequest -uri $uri).content | convertfrom-json
$my_chrome_info = $chrome_info_list.versions | where-object { $_.version -match $current_chrome_ver }
$DL_uri = ($my_chrome_info[0].downloads.chromedriver | where-object { $_.platform -eq "win64" }).url
# "https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.119/win64/chromedriver-win64.zip"

invoke-webrequest -uri $DL_uri -outfile "./tmp.zip"
expand-archive -path "./tmp.zip" -destinationpath "tmp" -force
move-item -path "./tmp/chromedriver-win64/chromedriver.exe" -destination "./chromedriver/chromedriver.exe" -force
remove-item "tmp*" -recurse