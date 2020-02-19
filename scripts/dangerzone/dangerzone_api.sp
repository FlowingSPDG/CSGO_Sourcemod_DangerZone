
/*
//////////////////////////////
//           API           //
//////////////////////////////
*/

#define VERSION "1.0"
public Plugin:myinfo =
{
	name = "SM Danger Zone Web API",
	author = "Shugo \"FlowingSPDG\" Kawamura",
	description = "DangerZone Web API Plugin",
	version = VERSION,
	url = "https://flowing.tokyo/aboutme"
};


// Web API system
ConVar g_APIURLCvar;
char g_APIURL[128];

// public void OnPluginStart()
public void OnAPIPluginStart()
{
	g_APIURLCvar = CreateConVar("yk_dzWeb_api_url", "", "URL the dangerzone api is hosted at");
	HookConVarChange(g_APIURLCvar, ApiInfoChanged);
}

public void API_AddKillToPlayer (int client) {
	if (IsFakeClient(client))
		return;
	char url[255];
	char sSteamID64[64];
	GetClientAuthId(client, AuthId_SteamID64, sSteamID64, sizeof(sSteamID64), true);
	FormatEx(url, 255, "match/dz/player/%s/update/kill", sSteamID64);
	Handle req = CreateRequest(k_EHTTPMethodPOST, url);
	if (req != INVALID_HANDLE) {
		SteamWorks_SendHTTPRequest(req);
	}
}

public void API_AddDeathToPlayer (int client) {
	if (IsFakeClient(client))
		return;
	char url[255];
	char sSteamID64[64];
	GetClientAuthId(client, AuthId_SteamID64, sSteamID64, sizeof(sSteamID64), true);
	FormatEx(url, 255, "match/dz/player/%s/update/death", sSteamID64);
	Handle req = CreateRequest(k_EHTTPMethodPOST, url);
	if (req != INVALID_HANDLE) {
		SteamWorks_SendHTTPRequest(req);
	}
}

public void API_AddWinToPlayer (int client) {
	if (IsFakeClient(client))
		return;
	char url[255];
	char sSteamID64[64];
	GetClientAuthId(client, AuthId_SteamID64, sSteamID64, sizeof(sSteamID64), true);
	FormatEx(url, 255, "match/dz/player/%s/update/win", sSteamID64);
	Handle req = CreateRequest(k_EHTTPMethodPOST, url);
	if (req != INVALID_HANDLE) {
		SteamWorks_SendHTTPRequest(req);
	}
}


// CVAR yk_DZweb_api_url changed
public void ApiInfoChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_APIURLCvar.GetString(g_APIURL, sizeof(g_APIURL));

	// Add a trailing backslash to the api url if one is missing.
	int len = strlen(g_APIURL);
	if (len > 0 && g_APIURL[len - 1] != '/') {
		StrCat(g_APIURL, sizeof(g_APIURL), "/");
	}

	LogMessage("yk_DZweb_api_url now set to %s", g_APIURL);
}

static Handle CreateRequest(EHTTPMethod httpMethod, const char[] apiMethod, any:...) {
	char url[1024];
	Format(url, sizeof(url), "%s%s", g_APIURL, apiMethod);

	char formattedUrl[1024];
	VFormat(formattedUrl, sizeof(formattedUrl), url, 3);

	LogMessage("Trying to create request to url %s", formattedUrl);

	Handle req = SteamWorks_CreateHTTPRequest(httpMethod, formattedUrl);
	if (StrEqual(g_APIURL, "")) {
		// Not using a web interface.
		return INVALID_HANDLE;
	} else if (req == INVALID_HANDLE) {
		LogError("Failed to create request to %s", formattedUrl);
		return INVALID_HANDLE;
	} else {
		SteamWorks_SetHTTPCallbacks(req, RequestCallback);
		return req;
	}
}