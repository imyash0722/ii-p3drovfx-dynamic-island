"""Unit tests for sports_fetcher helpers, scorecard null safety, and F1 fallbacks."""

import importlib.util
from pathlib import Path
import sys
import unittest
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / "sports" / "sports_fetcher.py"
SPEC = importlib.util.spec_from_file_location("sports_fetcher", SCRIPT)
sf = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sf)


class SportsFetcherTests(unittest.TestCase):
    def test_stat_str_avoids_literal_none(self):
        self.assertEqual(sf._stat_str(None, "0"), "0")
        self.assertEqual(sf._stat_str(None), "")
        self.assertEqual(sf._stat_str(0, "0"), "0")
        self.assertEqual(sf._stat_str("42", "0"), "42")

    def test_scorecard_handles_null_fields_and_quotes_ids(self):
        seen_urls = []
        payload = {
            "matchcards": [
                {
                    "headline": "Batting",
                    "inningsNumber": 1,
                    "teamName": "India",
                    "runs": None,
                    "total": "(20 ovs)",
                    "extras": None,
                    "playerDetails": [
                        {
                            "playerName": "Player A",
                            "dismissal": None,
                            "runs": None,
                            "ballsFaced": 10,
                            "fours": None,
                            "sixes": 1,
                        }
                    ],
                },
                {
                    "headline": "Bowling",
                    "inningsNumber": 1,
                    "teamName": "Australia",
                    "playerDetails": [
                        {
                            "playerName": "Bowler B",
                            "overs": "4.0",
                            "maidens": None,
                            "conceded": 24,
                            "wickets": None,
                            "economyRate": None,
                        }
                    ],
                },
            ]
        }

        def fake_fetch(url, timeout=10):
            seen_urls.append(url)
            return payload

        with mock.patch.object(sf, "fetch_json", side_effect=fake_fetch):
            out = sf.fetch_cricket_scorecard("24469/bad", "1539443&extra=1")

        self.assertEqual(len(seen_urls), 1)
        self.assertIn("24469%2Fbad/summary?event=1539443%26extra%3D1", seen_urls[0])
        self.assertEqual(len(out["innings"]), 1)
        bat = out["innings"][0]["batting"][0]
        bowl = out["innings"][0]["bowling"][0]
        self.assertEqual(bat["runs"], "0")
        self.assertEqual(bat["fours"], "0")
        self.assertEqual(bat["dismissal"], "")
        self.assertEqual(bowl["maidens"], "0")
        self.assertEqual(bowl["wickets"], "0")
        self.assertEqual(bowl["econ"], "0.00")

    def test_f1_latest_session_jolpica_handles_null_time(self):
        jolpica_payload = {
            "MRData": {
                "RaceTable": {
                    "Races": [
                        {
                            "raceName": "Qatar Grand Prix",
                            "Results": [
                                {
                                    "position": "1",
                                    "status": "Finished",
                                    "Driver": {"givenName": "Max", "familyName": "Verstappen", "code": "VER"},
                                    "Constructor": {"name": "Red Bull"},
                                    "Time": None,
                                }
                            ],
                        }
                    ]
                }
            }
        }

        def fake_fetch(url, timeout=7):
            if "openf1" in url:
                return None
            return jolpica_payload

        with mock.patch.object(sf, "fetch_json", side_effect=fake_fetch):
            res = sf.fetch_f1_latest_session()

        self.assertIsNotNone(res)
        self.assertEqual(res["event_name"], "Qatar Grand Prix")
        self.assertEqual(res["results"][0]["short"], "VER")
        self.assertEqual(res["results"][0]["gap"], "Finished")

    def test_f1_duration_and_gap_formatting(self):
        self.assertEqual(sf._format_f1_duration([83.1, 82.4, None]), "1:22.400")
        self.assertEqual(sf._format_f1_duration(58.5), "58.500s")
        self.assertEqual(sf._format_f1_gap(0.249), "+0.249s")
        self.assertEqual(sf._format_f1_gap(None, is_leader=True), "Leader")
        self.assertEqual(sf._format_f1_gap(0, dnf=True), "DNF")


if __name__ == "__main__":
    unittest.main()
