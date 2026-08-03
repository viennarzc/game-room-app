# Game catalog API study

Game Room v1 remains manual-entry first. No catalog credentials or networking
ship in the app.

## Preferred future option: IGDB behind a proxy

IGDB provides the stronger normalized model for games, covers, releases,
platform families, genres, and companies. It requires Twitch client-credentials
authentication, so its client secret must remain on a server. A thin proxy would
cache the access token, absorb provider schema changes, enforce limits, and
return a small Game Room DTO.

Commercial use and user-facing attribution must be confirmed with IGDB before
release. See the [IGDB API documentation](https://api-docs.igdb.com/) and
[Twitch authentication documentation](https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/).

## Evaluated alternative: RAWG behind a proxy

RAWG offers simpler REST search and broad coverage, but its API key is still
extractable if embedded in a client. Its terms require recurring attribution
and linking where RAWG data or images appear, which is a less natural fit for
the quiet shelf and detail UI. Plan and commercial-language differences should
be clarified before adoption.

See [RAWG API plans](https://rawg.io/apidocs) and
[RAWG API terms](https://rawg.io/tos_api).

## Future proxy contract

```text
GET /v1/games/search?q=<query>&limit=<count>
GET /v1/games/<catalog-id>
```

The proxy should return a stable `CatalogGame` DTO containing only catalog ID,
title, summary, cover URL, release date, platform IDs/names, genres, and company
names. It must never receive profile, journal, reminder, location, photo, or
played-with data.
