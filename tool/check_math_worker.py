"""Browser integration probe for the compiled worker client.

Compile tool/math_worker_browser_probe.dart to web/math_worker_probe.dart.js,
then serve web/ over HTTP. Requires the optional Python playwright package.
"""
import argparse
import asyncio
import json
from urllib.parse import urljoin

from playwright.async_api import async_playwright


async def check(args):
    async with async_playwright() as playwright:
        options = {"args": ["--no-sandbox"]}
        if args.chromium:
            options["executable_path"] = args.chromium
        browser = await playwright.chromium.launch(**options)
        page = await browser.new_page()
        await page.goto(urljoin(args.url, "privacy.html"))
        await page.add_script_tag(url=urljoin(args.url, "math_worker_probe.dart.js"))
        await page.wait_for_function("typeof mathWorkerProbeResult !== 'undefined'", timeout=60000)
        result = json.loads(await page.evaluate("mathWorkerProbeResult"))
        assert "error" not in result, result
        assert result["results"][0].startswith("5"), result
        assert result["results"][1] == "1/3", result
        assert "x" in result["results"][2], result
        assert result["ocrStartedUnloaded"] is True, result
        assert result["ocrLoadedOnDemand"] is True, result
        assert result["cancelled"] is True, result
        assert result["restarted"].startswith("4"), result
        print(json.dumps(result, indent=2))
        await browser.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", default="http://localhost:8765/")
    parser.add_argument("--chromium")
    asyncio.run(check(parser.parse_args()))
