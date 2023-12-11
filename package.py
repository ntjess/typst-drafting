import shutil
import typing as t
from pathlib import Path

from packaging.version import InvalidVersion
from packaging.version import Version as PkgVersion
import tomli

FilePath = t.Union[str, Path]


def create_package(
    source_folder: FilePath,
    typst_packages_folder: FilePath,
    package_paths: t.List[str | FilePath],
    version: str,
    package_name: str,
    namespace="preview",
    exist_ok=False,
):
    try:
        PkgVersion(version)
    except InvalidVersion:
        raise ValueError(f"{version} is not a valid version")

    upload_folder = Path(typst_packages_folder) / namespace / package_name / version
    if upload_folder.exists() and not exist_ok:
        raise FileExistsError(f"{upload_folder} already exists")
    elif upload_folder.exists():
        shutil.rmtree(upload_folder)
    upload_folder.mkdir(parents=True)

    src = Path(source_folder)
    for path in map(Path, package_paths):
        if path.is_dir():
            shutil.copytree(
                src.joinpath(path), upload_folder.joinpath(path), dirs_exist_ok=True
            )
        else:
            shutil.copy(src.joinpath(path), upload_folder.joinpath(path))
    return upload_folder


if "__main__" == __name__:
    import argparse
    import os

    here = Path(__file__).resolve().parent
    default_packages_folder = os.environ.get("typst_packages_folder", None)

    parser = argparse.ArgumentParser()
    parser.add_argument("toml", help="path to typst.toml", default=here / "typst.toml")
    parser.add_argument("--namespace", default="preview")
    parser.add_argument("--exist-ok", action="store_true")
    parser.add_argument("--typst-packages-folder", default=default_packages_folder)
    args = parser.parse_args()

    toml_file = Path(args.toml).resolve()
    with open(toml_file, "rb") as ifile:
        toml_text = tomli.load(ifile)  # type: ignore
    version = toml_text["package"]["version"]
    package_name = toml_text["package"]["name"]
    package_paths = toml_text["tool"]["packager"]["paths"]
    package_paths.append(toml_file.name)

    folder = create_package(
        Path(args.toml).resolve().parent,
        args.typst_packages_folder,
        package_paths,
        version,
        package_name,
        namespace=args.namespace,
        exist_ok=args.exist_ok,
    )
    print(f"Created package in {folder}")
