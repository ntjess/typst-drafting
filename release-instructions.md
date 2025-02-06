# Ensure `typst.toml` is up to date
-  Bump `version`
-  Ensure no new filepaths are needed in `tool.packager`

# Ensure Typst readme is up to date
-  Examples for new functionality present in [overview.typ](./docs/overview/main.typ)
-  Compile overview to PDF and ensure everything looks good

# Update generated readme
- Ensure `showman` is installed:
    ```sh
    pip install showman
    ```
-  Comment out `--git_url` in `update_readme.sh`, then run it:
    ```sh
    ./update_readme.sh
    ```
You should see `readme.md` update, and you can verify the images look good.
-  Uncomment `--git_url` in `update_readme.sh`, change the referenced tag to the new version, then run the script again. This wil replace each image reference in the readme with a link to GitHub assets, meaning we don't have to package the images with the release.
-  Add all updates to git:
    ```sh
    git add .
    git commit -m "Update readme for release"
    ```
-  Tag the repo with the new version:
    ```sh
    git tag vX.Y.Z
    ```
-  Push the code and tag to GitHub:
    ```sh
    git push
    git push --tags
    ```

# Create a new release
- Clone [`typst/packages`](https://github.com/typst/packages) locally
- Inside `typst/packages`, create a new branch for your changes
- Run showman to bundle assets into the new release:
    ```sh
    showman package ./typst.toml \
        --typst_packages_folder /path/to/typst/packages/packages/ \
        --namespace preview \
        --overwrite
    ```

> [!NOTE]
> The `typst_packages_folder` is what holds the `preview` folder, not the repo root. So make sure it's `packages/packages/` (which contains `preview`) and not just `packages/`.

- Submit a PR upstream to typst/packages

:tada: You're done! The new release should be available in the Typst universe.
