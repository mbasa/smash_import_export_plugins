part of smash_import_export_plugins;

/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const TITLE_KML = "KML";

class KmlExportPlugin extends AExportPlugin {
  ProjectDb projectDb;
  BuildContext context;

  @override
  void setContext(BuildContext context) {
    this.context = context;
  }

  @override
  Icon getIcon() {
    return Icon(
      MdiIcons.googleEarth,
      color: SmashColors.mainDecorations,
    );
  }

  @override
  String getTitle() {
    return TITLE_KML;
  }

  @override
  String getDescription() {
    return IEL.of(context).exportWidget_exportToKml;
  }

  @override
  void setProjectDatabase(ProjectDb projectDb) {
    this.projectDb = projectDb;
  }

  @override
  Widget getExportPage() {
    return KmlExportWidget(
      projectDb: projectDb,
    );
  }

  @override
  Widget getSettingsPage() {
    return null;
  }
}

class KmlExportWidget extends StatefulWidget {
  final ProjectDb projectDb;
  KmlExportWidget({Key key, this.projectDb}) : super(key: key);

  @override
  State<KmlExportWidget> createState() => _KmlExportWidgetState();
}

class _KmlExportWidgetState extends State<KmlExportWidget>
    with AfterLayoutMixin {
  bool building = true;
  String outFilePath;

  @override
  void afterFirstLayout(BuildContext context) {
    buildKml();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(TITLE_KML)),
        body: building
            ? Center(
                child: SmashCircularProgress(),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SmashUI.titleText(
                      IEL.of(context).exportWidget_kmlExported,
                    ),
                    SmashUI.smallText(
                      outFilePath,
                    ),
                  ],
                ),
              ));
  }

  Future<void> buildKml() async {
    var exportsFolder = await Workspace.getExportsFolder();
    var ts = HU.TimeUtilities.DATE_TS_FORMATTER.format(DateTime.now());
    outFilePath =
        HU.FileUtilities.joinPaths(exportsFolder.path, "smash_export_$ts.kml");

    await GpxExporter.exportDb(widget.projectDb, File(outFilePath), true);

    setState(() {
      building = false;
    });
  }
}
