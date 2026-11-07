#!/usr/bin/env python3
"""
sports_fetcher.py - Real-time sports aggregator for Quickshell Left Sidebar
Tracks:
- Cricket: India (IND) and Australia (AUS)
- Tennis: Carlos Alcaraz and Jannik Sinner (+ ATP Rankings)
- Formula 1: Lewis Hamilton and Oscar Piastri (+ Next Race Schedule & Standings)

Zero-auth, highly resilient, with adaptive sleep and local caching.
"""

import sys
import os
import json
import time
import re
import argparse
from datetime import datetime, timezone, timedelta
import urllib.request
import urllib.error

USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 QuickshellSports/1.0"
IST_OFFSET = timedelta(hours=5, minutes=30)
STATE_DIR = os.path.expanduser("~/.local/state/quickshell/sports")
OUTPUT_FILE = os.path.join(STATE_DIR, "sports_data.json")

def is_target_team(name, short=""):
    text = f"{name} {short}".lower()
    tokens = set(re.findall(r"\b[a-z0-9]+\b", text))
    return bool(tokens & {"india", "ind", "australia", "aus"})

def fetch_json(url, timeout=7):
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if resp.status == 200:
                return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        # print(f"Error fetching {url}: {e}", file=sys.stderr)
        pass
    return None

def parse_iso_datetime(dt_str):
    if not dt_str:
        return None
    dt_str = dt_str.replace("Z", "+00:00")
    try:
        return datetime.fromisoformat(dt_str)
    except Exception:
        return None

def format_ist(dt):
    if not dt:
        return ""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    ist_dt = dt.astimezone(timezone(IST_OFFSET))
    return ist_dt.strftime("%d %b, %H:%M IST")

# ================= CRICKET =================
def fetch_cricket():
    url = "https://site.api.espn.com/apis/personalized/v2/scoreboard/header?sport=cricket&region=in&tz=Asia/Calcutta"
    data = fetch_json(url)
    matches = []
    has_live = False

    if not data or "sports" not in data or not data["sports"]:
        return {"has_live": False, "matches": []}

    for sport in data["sports"]:
        for league in sport.get("leagues", []):
            league_name = league.get("name", "")
            for ev in league.get("events", []):
                ev_name = ev.get("name", "")
                short_name = ev.get("shortName", "")
                desc = ev.get("description", "")

                comps = ev.get("competitors", [])
                team1 = {"name": "TBD", "short": "TBD", "score": "", "logo": "", "is_favorite": False}
                team2 = {"name": "TBD", "short": "TBD", "score": "", "logo": "", "is_favorite": False}

                if len(comps) >= 1:
                    c1 = comps[0]
                    short1 = c1.get("abbreviation", c1.get("name", ""))
                    name1 = c1.get("displayName", short1)
                    team1 = {
                        "name": name1,
                        "short": short1,
                        "score": c1.get("score", ""),
                        "logo": c1.get("logo", ""),
                        "is_favorite": is_target_team(name1, short1)
                    }
                if len(comps) >= 2:
                    c2 = comps[1]
                    short2 = c2.get("abbreviation", c2.get("name", ""))
                    name2 = c2.get("displayName", short2)
                    team2 = {
                        "name": name2,
                        "short": short2,
                        "score": c2.get("score", ""),
                        "logo": c2.get("logo", ""),
                        "is_favorite": is_target_team(name2, short2)
                    }

                # Only include if India or Australia is playing
                event_has_target = team1["is_favorite"] or team2["is_favorite"] or is_target_team(ev_name, short_name) or is_target_team(desc)
                if not event_has_target:
                    continue

                status = ev.get("status", "pre")  # "in", "pre", "post"
                full_status = ev.get("fullStatus", {})
                status_desc = full_status.get("type", {}).get("description", ev.get("summary", ""))
                session_text = full_status.get("session", "")
                long_summary = full_status.get("longSummary", "")
                summary = full_status.get("summary", "")

                is_live = (status == "in")
                if is_live:
                    has_live = True

                # Find toss note if present
                toss_note = ""
                for n in ev.get("notes", []):
                    if n.get("type") == "toss":
                        toss_note = n.get("text", "")
                        break
                if not toss_note and "toss" in long_summary.lower():
                    toss_note = long_summary

                # Format time
                date_str = ev.get("date", "")
                dt = parse_iso_datetime(date_str)
                time_local = format_ist(dt) if dt else ""

                match_item = {
                    "id": ev.get("id", ""),
                    "title": ev.get("title", ev.get("name", "")),
                    "short_name": ev.get("shortName", ""),
                    "league": league_name,
                    "format": ev.get("eventType", ev.get("class", {}).get("eventType", "Match")),
                    "status": status,
                    "is_live": is_live,
                    "status_desc": status_desc,
                    "session_text": session_text,
                    "summary": summary or long_summary,
                    "toss": toss_note,
                    "venue": ev.get("location", ""),
                    "time_local": time_local,
                    "team1": team1,
                    "team2": team2,
                    "link": ev.get("link", "")
                }
                matches.append(match_item)

    # Sort matches: live first, then upcoming, then recent completed
    status_order = {"in": 0, "pre": 1, "post": 2}
    matches.sort(key=lambda m: (status_order.get(m["status"], 3), m.get("time_local", "")))

    return {"has_live": has_live, "matches": matches[:6]}


# ================= TENNIS =================
def fetch_tennis():
    # 1. ATP Rankings
    rank_url = "https://site.api.espn.com/apis/site/v2/sports/tennis/atp/rankings"
    rank_data = fetch_json(rank_url)

    favorites_info = {
        "Jannik Sinner": {"name": "Jannik Sinner", "short": "J. Sinner", "country": "ITA", "flag": "🇮🇹", "rank": "-", "points": "-", "change": ""},
        "Carlos Alcaraz": {"name": "Carlos Alcaraz", "short": "C. Alcaraz", "country": "ESP", "flag": "🇪🇸", "rank": "-", "points": "-", "change": ""}
    }
    top_rankings = []

    if rank_data and "rankings" in rank_data and rank_data["rankings"]:
        ranks = rank_data["rankings"][0].get("ranks", [])
        for r in ranks:
            athlete = r.get("athlete", {})
            name = athlete.get("displayName", "")
            current_rank = r.get("current", 0)
            pts = int(r.get("points", 0))

            if current_rank <= 5:
                top_rankings.append({
                    "rank": current_rank,
                    "name": name,
                    "points": pts,
                    "is_favorite": name in favorites_info
                })

            for fav_name in favorites_info:
                if fav_name.lower() in name.lower():
                    favorites_info[fav_name]["rank"] = current_rank
                    favorites_info[fav_name]["points"] = f"{pts:,}"

    # 2. ATP Scoreboard (matches)
    sb_url = "https://site.api.espn.com/apis/site/v2/sports/tennis/atp/scoreboard"
    sb_data = fetch_json(sb_url)
    matches = []
    has_live = False

    target_players = ["alcaraz", "sinner"]

    if sb_data and "events" in sb_data:
        for ev in sb_data.get("events", []):
            tournament_name = ev.get("name", "ATP Tournament")
            venue_info = ev.get("venue", {}).get("fullName", "")

            for grp in ev.get("groupings", []):
                for comp in grp.get("competitions", []):
                    comp_name = comp.get("notes", [{}])[0].get("text", "") if comp.get("notes") else comp.get("round", {}).get("displayName", "")
                    competitors = comp.get("competitors", [])
                    matched = False
                    p1_info = {}
                    p2_info = {}

                    for idx, c in enumerate(competitors):
                        athlete = c.get("athlete", {})
                        p_name = athlete.get("displayName", "")
                        is_fav = any(tp in p_name.lower() for tp in target_players)
                        if is_fav:
                            matched = True

                        linescores = [int(ls.get("value", 0)) for ls in c.get("linescores", [])]
                        p_data = {
                            "name": p_name,
                            "seed": c.get("curScore", ""),
                            "score": c.get("score", ""),
                            "sets": linescores,
                            "winner": c.get("winner", False),
                            "is_favorite": is_fav
                        }
                        if idx == 0:
                            p1_info = p_data
                        else:
                            p2_info = p_data

                    if matched and p1_info and p2_info:
                        comp_status = comp.get("status", {}).get("type", {})
                        status_state = comp_status.get("state", "pre")
                        status_desc = comp_status.get("description", comp_status.get("detail", ""))
                        is_live = (status_state == "in")
                        if is_live:
                            has_live = True

                        matches.append({
                            "tournament": tournament_name,
                            "round": comp_name or "Match",
                            "status": status_state,
                            "is_live": is_live,
                            "status_desc": status_desc,
                            "player1": p1_info,
                            "player2": p2_info
                        })

    return {
        "has_live": has_live,
        "favorites": list(favorites_info.values()),
        "top_rankings": top_rankings,
        "matches": matches
    }


# ================= FORMULA 1 =================
def fetch_f1():
    # 1. Next Race
    next_url = "https://api.jolpi.ca/ergast/f1/current/next.json"
    next_data = fetch_json(next_url)
    next_race_info = None

    if next_data and "MRData" in next_data and "RaceTable" in next_data["MRData"]:
        races = next_data["MRData"]["RaceTable"].get("Races", [])
        if races:
            r = races[0]
            race_name = r.get("raceName", "Grand Prix")
            circuit_name = r.get("Circuit", {}).get("circuitName", "")
            locality = r.get("Circuit", {}).get("Location", {}).get("locality", "")
            country = r.get("Circuit", {}).get("Location", {}).get("country", "")

            # Timings
            race_date = r.get("date", "")
            race_time = r.get("time", "00:00:00Z")
            race_dt = parse_iso_datetime(f"{race_date}T{race_time}")

            now_utc = datetime.now(timezone.utc)
            countdown_seconds = int((race_dt - now_utc).total_seconds()) if race_dt else 0

            sessions = []
            session_keys = [
                ("Practice 1", r.get("FirstPractice")),
                ("Practice 2", r.get("SecondPractice")),
                ("Practice 3", r.get("ThirdPractice")),
                ("Sprint Shootout", r.get("SprintQualifying")),
                ("Sprint", r.get("Sprint")),
                ("Qualifying", r.get("Qualifying")),
                ("Grand Prix", {"date": race_date, "time": race_time})
            ]

            for s_name, s_data in session_keys:
                if not s_data:
                    continue
                s_dt = parse_iso_datetime(f"{s_data.get('date', '')}T{s_data.get('time', '00:00:00Z')}")
                if s_dt:
                    is_past = (s_dt < now_utc)
                    sessions.append({
                        "name": s_name,
                        "time_local": format_ist(s_dt),
                        "is_past": is_past
                    })

            next_race_info = {
                "race_name": race_name,
                "circuit": circuit_name,
                "location": f"{locality}, {country}" if locality else country,
                "race_time_local": format_ist(race_dt),
                "countdown_seconds": max(0, countdown_seconds),
                "countdown_text": format_countdown(countdown_seconds),
                "sessions": sessions
            }

    # 2. Driver Standings
    driver_url = "https://api.jolpi.ca/ergast/f1/current/driverStandings.json"
    driver_data = fetch_json(driver_url)
    driver_standings = []

    fav_drivers = {
        "hamilton": {"number": 44, "color": "#E80020", "short": "HAM"},
        "piastri": {"number": 81, "color": "#FF8000", "short": "PIA"}
    }

    if driver_data and "MRData" in driver_data and "StandingsTable" in driver_data["MRData"]:
        lists = driver_data["MRData"]["StandingsTable"].get("StandingsLists", [])
        if lists:
            for d in lists[0].get("DriverStandings", []):
                d_info = d.get("Driver", {})
                first_name = d_info.get("givenName", "")
                last_name = d_info.get("familyName", "")
                full_name = f"{first_name} {last_name}"
                pos = int(d.get("position", 0))
                pts = d.get("points", "0")
                cons_name = d.get("Constructors", [{}])[0].get("name", "Team") if d.get("Constructors") else "Team"

                is_fav = False
                color = ""
                for k, v in fav_drivers.items():
                    if k in last_name.lower():
                        is_fav = True
                        color = v["color"]
                        break

                driver_standings.append({
                    "pos": pos,
                    "driver": full_name,
                    "constructor": cons_name,
                    "points": pts,
                    "is_favorite": is_fav,
                    "color": color
                })

    # 3. Constructor Standings
    cons_url = "https://api.jolpi.ca/ergast/f1/current/constructorStandings.json"
    cons_data = fetch_json(cons_url)
    constructor_standings = []

    fav_teams = {
        "ferrari": "#E80020",
        "mclaren": "#FF8000"
    }

    if cons_data and "MRData" in cons_data and "StandingsTable" in cons_data["MRData"]:
        lists = cons_data["MRData"]["StandingsTable"].get("StandingsLists", [])
        if lists:
            for c in lists[0].get("ConstructorStandings", [])[:5]:
                t_name = c.get("Constructor", {}).get("name", "Team")
                pos = int(c.get("position", 0))
                pts = c.get("points", "0")

                is_fav = any(ft in t_name.lower() for ft in fav_teams)
                color = ""
                for ft, clr in fav_teams.items():
                    if ft in t_name.lower():
                        color = clr
                        break

                constructor_standings.append({
                    "pos": pos,
                    "team": t_name,
                    "points": pts,
                    "is_favorite": is_fav,
                    "color": color
                })

    return {
        "next_race": next_race_info,
        "driver_standings": driver_standings[:10],
        "constructor_standings": constructor_standings
    }


def format_countdown(seconds):
    if seconds <= 0:
        return "Race Weekend Active"
    days = seconds // 86400
    hours = (seconds % 86400) // 3600
    minutes = (seconds % 3600) // 60
    if days > 0:
        return f"{days}d {hours}h {minutes}m"
    return f"{hours}h {minutes}m"


def fetch_all():
    cricket = fetch_cricket()
    tennis = fetch_tennis()
    f1 = fetch_f1()

    now_ist = datetime.now(timezone(IST_OFFSET)).strftime("%d %b, %H:%M:%S IST")
    has_any_live = cricket["has_live"] or tennis["has_live"]

    output = {
        "updated_at": now_ist,
        "is_live_active": has_any_live,
        "cricket": cricket,
        "tennis": tennis,
        "f1": f1
    }
    return output


def save_data(data):
    os.makedirs(STATE_DIR, exist_ok=True)
    temp_file = OUTPUT_FILE + ".tmp"
    with open(temp_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(temp_file, OUTPUT_FILE)


def main():
    parser = argparse.ArgumentParser(description="Quickshell Sports Aggregator")
    parser.add_argument("--once", action="store_true", help="Fetch once and exit")
    parser.add_argument("--daemon", action="store_true", help="Run background adaptive loop")
    args = parser.parse_args()

    if args.once or not args.daemon:
        data = fetch_all()
        save_data(data)
        print(f"Sports data successfully saved to {OUTPUT_FILE} at {data['updated_at']}")
        return

    # Daemon mode: Adaptive polling
    while True:
        try:
            data = fetch_all()
            save_data(data)
            # If any live match is underway, poll every 30s; otherwise poll every 10 minutes
            poll_interval = 35 if data.get("is_live_active") else 600
            time.sleep(poll_interval)
        except Exception as e:
            # print(f"Error in sports daemon loop: {e}", file=sys.stderr)
            time.sleep(60)

if __name__ == "__main__":
    main()
