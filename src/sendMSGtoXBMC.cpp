// sendMSGtoXBMC.cpp
//
// @AUTHOR: Sven Burkard <dev@sven-burkard.de>
// @DESC..: sends a xbmc-notification 
// @PARAMS: xbmcHost, xbmcPort, xbmcUser, xbmcPassword, title, message
/////////////////////////////////////////////////////////////////////////


#include <iostream>     // cout...
#include <curl/curl.h>


using namespace std;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool sendMSGtoXBMC(string xbmcHost, string xbmcPort, string xbmcUser, string xbmcPassword, string title, string message)
{
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//  cout << "xbmcHost: " << xbmcHost << "| xbmcPort: " << xbmcPort << "| xbmcUser: " << xbmcUser << "| xbmcPassword: " << xbmcPassword << "| title: " << title << "| message: " << message << "\n";     // debug


  CURL *curl;
  CURLcode result;
  struct curl_slist *reqHeaderList=NULL;


  // initialize everything possible. this sets all known bits.
  curl_global_init(CURL_GLOBAL_ALL);

  // get a curl handle 
  curl = curl_easy_init();


  if(!curl)
  {
    cout << "ERROR: curl_easy_init() failed\n";
    return false;
  }


  string reqUrl       = "http://" + xbmcHost + ":" + xbmcPort + "/jsonrpc ";
  string reqAuth      = xbmcUser + ":" + xbmcPassword;
  string reqHeader    = "Content-type: application/json";
  string reqPostData  = "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"GUI.ShowNotification\",\"params\":{\"title\":\"" + title + "\",\"message\":\"" + message + "\"}}";

  // append reqHeader to reqHeaderList
  reqHeaderList       = curl_slist_append(reqHeaderList, reqHeader.c_str());


  // set url
  curl_easy_setopt(curl, CURLOPT_URL, reqUrl.c_str());

  // set login/password
  curl_easy_setopt(curl, CURLOPT_USERPWD, reqAuth.c_str());

  // set http header
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, reqHeaderList);

  // set POST data
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, reqPostData.c_str());


  // perform the request and push the return code into result 
  result = curl_easy_perform(curl);


  // check for errors
  if(result != CURLE_OK)
  {
    cout << "ERROR: curl_easy_perform() failed: " <<  curl_easy_strerror(result) << "\n";
    return false;
  }


  // cleanup
  curl_easy_cleanup(curl);
  curl_global_cleanup();


  return true;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char* argv[])
{
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//  cout << "argc: " << argc << "\n";                       // debug

  if( argc != 7)
  {
    cout << "ERROR: argc is invalid (should be 6 params)\n";
    cout << "ERROR: all params must be defined: xbmcHost, xbmcPort, xbmcUser, xbmcPassword, title, message\n";
    return 1;
  }

  if(!sendMSGtoXBMC(argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]))
  {
    cout << "ERROR: sendMSGtoXBMC() failed\n";
    return 1;
  }


  return 0;
}

