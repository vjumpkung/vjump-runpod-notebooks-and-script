import gdown
import os
import zipfile
import argparse


def main(path: str, url: str):
    os.makedirs(path, exist_ok=True)
    os.chdir(path)
    file = gdown.download(url, fuzzy=True)
    if zipfile.is_zipfile(file):
        with zipfile.ZipFile(file, "r") as zip_ref:
            zip_ref.extractall()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Download files from Google Drive and extract if ZIP"
    )

    parser.add_argument(
        "--path",
        type=str,
        required=True,
        help="Path where the file will be downloaded and extracted",
    )

    parser.add_argument(
        "--url",
        type=str,
        required=True,
        help="Google Drive URL of the file to download",
    )

    args = parser.parse_args()
    main(args.path, args.url)
