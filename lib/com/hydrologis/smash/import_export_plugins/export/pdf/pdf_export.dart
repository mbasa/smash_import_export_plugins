part of smash_import_export_plugins;

/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const TITLE_PDF = "PDF";

class PdfExportPlugin extends AExportPlugin {
  ProjectDb projectDb;
  BuildContext context;

  @override
  void setContext(BuildContext context) {
    this.context = context;
  }

  @override
  Icon getIcon() {
    return Icon(
      MdiIcons.filePdfBox,
      color: SmashColors.mainDecorations,
    );
  }

  @override
  String getTitle() {
    return TITLE_PDF;
  }

  @override
  String getDescription() {
    return IEL.of(context).exportWidget_exportToPortableDocumentFormat;
  }

  @override
  void setProjectDatabase(ProjectDb projectDb) {
    this.projectDb = projectDb;
  }

  @override
  Widget getExportPage() {
    return PdfExportWidget(
      projectDb: projectDb,
    );
  }

  @override
  Widget getSettingsPage() {
    return null;
  }
}

class PdfExportWidget extends StatefulWidget {
  final ProjectDb projectDb;
  PdfExportWidget({Key key, this.projectDb}) : super(key: key);

  @override
  State<PdfExportWidget> createState() => _PdfExportWidgetState();
}

class _PdfExportWidgetState extends State<PdfExportWidget>
    with AfterLayoutMixin {
  bool building = true;
  String outFilePath;

  @override
  void afterFirstLayout(BuildContext context) {
    buildPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(TITLE_PDF)),
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
                      IEL.of(context).exportWidget_pdfExported,
                    ),
                    SmashUI.smallText(
                      outFilePath,
                    ),
                  ],
                ),
              ));
  }

  Future<void> buildPdf() async {
    var exportsFolder = await Workspace.getExportsFolder();
    var ts = HU.TimeUtilities.DATE_TS_FORMATTER.format(DateTime.now());
    outFilePath =
        HU.FileUtilities.joinPaths(exportsFolder.path, "smash_export_$ts.pdf");

    await PdfExporter.exportDb(widget.projectDb, File(outFilePath));

    setState(() {
      building = false;
    });
  }
}
