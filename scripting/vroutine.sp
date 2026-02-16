#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1
#define VROUTINE_FILE "vroutine.txt"
#define VROUTINE_COUNT_FILE "vroutine_count.txt"
#define VROUTINE_CLOCKTALE_FILE "vroutine_clocktale.txt"
int g_count = 0;
ConVar g_sync_with_time;

public Plugin myinfo =
{
	name = "vroutine",
	author = "TheRedEnemy",
	description = "",
	version = "1.0.3",
	url = "https://github.com/theredenemy/vroutine"
};

void makeConfig()
{
	char path[PLATFORM_MAX_PATH];
	char path2[PLATFORM_MAX_PATH];
	char path_clocktale[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", VROUTINE_FILE);
	BuildPath(Path_SM, path2, sizeof(path2), "configs/%s", VROUTINE_COUNT_FILE);
	BuildPath(Path_SM, path_clocktale, sizeof(path_clocktale), "configs/%s", VROUTINE_CLOCKTALE_FILE);
	if (!FileExists(path))
	{
		PrintToServer(path);
		KeyValues kv = new KeyValues("vroutine");
		kv.SetString("0", "changelevel ask");
		kv.SetString("1", "changelevel cp_dustbowl");
		kv.SetString("2", "changelevel askask");
		kv.Rewind();
		kv.ExportToFile(path);
		delete kv;
	}
	if (!FileExists(path2))
	{
		KeyValues kv = new KeyValues("count");
		kv.SetString("state", "0");
		kv.Rewind();
		kv.ExportToFile(path2);
		delete kv;
	}
	if (!FileExists(path_clocktale))
	{
		KeyValues kv = new KeyValues("clocktale");
		kv.SetString("2_sound", "/npc/combine_soldier/vo/storm.wav");
		kv.SetString("2_hint_text", "clock tale");
		kv.SetString("2_cmd", "echo clocktale");
		kv.SetString("2_chat_text", "clock tale");
		kv.Rewind();
		kv.ExportToFile(path_clocktale);
		delete kv;
	}
}
public int GetCount()
{
	char path[PLATFORM_MAX_PATH];
	char path2[PLATFORM_MAX_PATH];
	int count;
	int timestamp = GetTime();
	char hour_str[128];
	int convarint = GetConVarInt(g_sync_with_time);
	// 1771228800
	FormatTime(hour_str, sizeof(hour_str), "%H", timestamp);
	PrintToServer(hour_str);
	int hour = StringToInt(hour_str);
	char count_str[128];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", VROUTINE_COUNT_FILE);
	BuildPath(Path_SM, path2, sizeof(path2), "configs/%s", VROUTINE_FILE);
	KeyValues kv = new KeyValues("count");
	KeyValues kv2 = new KeyValues("vroutine");
	if (!kv.ImportFromFile(path))
	{
		PrintToServer("NO FILE");
		delete kv;
		delete kv2;
		return 0;
	}
	if (!kv2.ImportFromFile(path2))
	{
		PrintToServer("NO FILE");
		delete kv;
		delete kv2;
		return 0;
	}
	
	if (kv.JumpToKey("state", false))
	{
		count = KvGetNum(kv, NULL_STRING);
		kv.Rewind();
		//delete kv;
	}
	else
	{
		//delete kv;
		count = 0;
	}
	delete kv;
	KeyValues kv3 = new KeyValues("count");
	if (convarint == 1)
	{
		// Sync With Time
		if (hour == 00)
		{
			count = 0;
		}
		if (hour == 01)
		{
			count = 1;
		}
		if (hour == 02)
		{
			count = 2;
		}
	}
	
	int sum = count + 1;
	IntToString(sum, count_str, sizeof(count_str));
	PrintToServer(count_str);
	if (kv2.JumpToKey(count_str, false))
	{
		//PrintToServer("Key Found");
		kv3.SetString("state", count_str);
		kv3.Rewind();
		kv2.Rewind();
		kv3.ExportToFile(path);
	}
	else
	{
		kv3.SetString("state", "0");
		kv3.Rewind();
		kv3.ExportToFile(path);
	}
	delete kv3;
	delete kv2;
	
	return count;
	
}

public void OnPluginStart()
{
	int timestamp = GetTime();
	char hour_str[128];
	// 1771228800
	FormatTime(hour_str, sizeof(hour_str), "%H", timestamp);
	int hour = StringToInt(hour_str);
	makeConfig();
	g_sync_with_time = CreateConVar("v_sync_with_time", "0");
	AutoExecConfig(true);
	RegServerCmd("vroutine_count", vroutine_count_command);
	RegServerCmd("v_routine", vroutine_command);
	RegServerCmd("v_door", vroutine_door);
	if (hour == 00 || hour == 01 || hour == 02)
	{
		g_count = GetCount();
		char count_str[128];
		IntToString(g_count, count_str, sizeof(count_str));
		PrintToServer(count_str);
	}
	
	PrintToServer("vroutine Has Started");

}
public Action vroutine_count_command(int args)
{
	g_count = GetCount();
	char count_str[128];
	IntToString(g_count, count_str, sizeof(count_str));
	PrintToServer(count_str);
	return Plugin_Handled;
}

public Action vroutine_command(int args)
{
	char path_clocktale[PLATFORM_MAX_PATH];
	char sound[PLATFORM_MAX_PATH];
	char hint_text[256];
	char cmd[256];
	char chat_text[256];
	
	char sound_cfg[256];
	char hint_text_cfg[256];
	char cmd_cfg[256];
	char chat_text_cfg[256];

	char count_str[128];
	IntToString(g_count, count_str, sizeof(count_str));
	Format(sound_cfg, sizeof(sound_cfg), "%s_sound", count_str);
	Format(hint_text_cfg, sizeof(hint_text_cfg), "%s_hint_text", count_str);
	Format(cmd_cfg, sizeof(cmd_cfg), "%s_cmd", count_str);
	Format(chat_text_cfg, sizeof(chat_text_cfg), "%s_chat_text", count_str);


	BuildPath(Path_SM, path_clocktale, sizeof(path_clocktale), "configs/%s", VROUTINE_CLOCKTALE_FILE);
	KeyValues kv = new KeyValues("clocktale");

	if (!kv.ImportFromFile(path_clocktale))
	{
		PrintToServer("NO FILE");
		delete kv;
		return Plugin_Handled;
	}
	if (kv.JumpToKey(sound_cfg, false))
	{
		kv.GetString(NULL_STRING, sound, sizeof(sound));
		kv.Rewind();
		
		PrecacheSound(sound, true);
		
		EmitSoundToAll(sound);
	}
	if (kv.JumpToKey(hint_text_cfg, false))
	{
		kv.GetString(NULL_STRING, hint_text, sizeof(hint_text));
		kv.Rewind();
		PrintHintTextToAll("ADMIN: %s", hint_text);
	}
	if (kv.JumpToKey(cmd_cfg, false))
	{
		kv.GetString(NULL_STRING, cmd, sizeof(cmd));
		kv.Rewind();
		ServerCommand("%s", cmd);
	}
	if (kv.JumpToKey(chat_text_cfg, false))
	{
		kv.GetString(NULL_STRING, chat_text, sizeof(chat_text));
		kv.Rewind();
		PrintToChatAll("ADMIN: %s", chat_text);
	}
	delete kv;
	return Plugin_Handled;
	
}

public Action vroutine_door(int args)
{
	char path[PLATFORM_MAX_PATH];
	char cmd[256];
	char count_str[128];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", VROUTINE_FILE);
	KeyValues kv = new KeyValues("vroutine");
	if (!kv.ImportFromFile(path))
	{
		PrintToServer("NO FILE");
		delete kv;
		return Plugin_Handled;
	}
	IntToString(g_count, count_str, sizeof(count_str));
	if (kv.JumpToKey(count_str, false))
	{
		kv.GetString(NULL_STRING, cmd, sizeof(cmd));
		kv.Rewind();
		ServerCommand("%s", cmd);
	}
	delete kv;
	return Plugin_Handled;

}