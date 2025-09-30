![](./media/solutions-microsoft-logo-small.png)

# Azure Data SQL Samples Repository
This GitHub repository contains code samples that demonstrate how to use Microsoft's Azure Data products including SQL Server, Azure SQL Database, Azure Synapse, and Azure SQL Edge. Each sample includes a README file that explains how to run and use the sample.

Please note that specific features, such as In-Memory OLTP, are edition-specific for SQL Server. These features will only be available if the edition that supports them is used to run the sample.

## Releases in this repository

Releases provide convenient downloads of sample databases and applications, eliminating the need to build them from source code. This SQL Server samples repository offers the following notable releases:

  - [Wide World Importers sample database v1.0](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0) is the main sample for SQL Server 2016 and Azure SQL Database. It contains both an OLTP and an OLAP database.
  - [In-Memory OLTP Performance Demo v1.0](https://github.com/Microsoft/sql-server-samples/releases/tag/in-memory-oltp-demo-v1.0) illustrates the performance benefits of the In-Memory OLTP technology built into SQL Server and Azure SQL Database.
  - [IoT Smart Grid sample v1.0](https://github.com/Microsoft/sql-server-samples/releases/tag/iot-smart-grid-v1.0) illustrates how SQL Server can be leveraged to ingest data from IoT devices and sensors, and how you can run analytics on that data.

To see the complete list of resources in this repository, navigate to [Releases](https://github.com/Microsoft/sql-server-samples/releases)
(this now includes an entity diagram of Northwind database) to help visual learners.

## WideWorldImporters Revenue & Margin Dashboard

This repository includes a comprehensive interactive dashboard for analyzing 12-month revenue and margin trends from the WideWorldImportersDW database. The dashboard provides business intelligence insights through modern web visualizations and integrates with Supabase for cloud data hosting.

### Features

- **Interactive Visualizations**: Monthly and quarterly revenue/margin trend charts using Chart.js
- **Business Analytics**: Top products and customer segment analysis with performance metrics
- **Real-time Data**: Supabase integration for live dashboard updates
- **Responsive Design**: Modern web interface that works across devices
- **Growth Analysis**: Month-over-month and quarter-over-quarter growth calculations

### Components

The dashboard solution consists of four main components:

1. **SQL Queries** (`revenue-margin-queries.sql`): Comprehensive queries for extracting revenue and margin trends from WideWorldImportersDW, including monthly/quarterly aggregations and top performer analysis.

2. **Data Importer** (`data-importer.py`): Python script that connects to the database, executes queries, and loads results into Supabase tables for dashboard consumption.

3. **Interactive Dashboard** (`dashboard/index.html`): Modern web interface with Chart.js visualizations, including line charts for trends, bar charts for comparisons, and data tables for detailed analysis.

4. **Deployment Configuration** (`dashboard/edge-function.js`): Supabase Edge Function for production hosting and API endpoints.

### Quick Start

1. **Set up Supabase**: Configure your Supabase project and obtain API keys
2. **Import Data**: Run `python data-importer.py` to load sample data
3. **View Dashboard**: Open `dashboard/index.html` in a web browser or deploy via Supabase Edge Functions

For detailed setup instructions, configuration options, and customization guidance, see [`README-dashboard.md`](README-dashboard.md).

### Database Requirements

The dashboard is designed to work with the WideWorldImportersDW sample database and uses the following key tables:
- `Fact.Sale` - Sales transaction data with revenue and margin columns
- `Dimension.Date` - Date dimension for time-based aggregations
- `Dimension.Stock Item` - Product information for top products analysis
- `Dimension.Customer` - Customer data for segment analysis

## Working in GitHub
To contribute on GitHub, follow these steps:

- Visit https://github.com/microsoft/sql-server-samples and fork the repository.
- Work in your forked repository.
- When you're ready to make changes or publish your sample for the first time, submit a pull request into the 'master' branch of 'sql-server-samples'.
- One of the approvers will review your request and either accept or reject the pull request.

Each sample should be in its own folder with a README.md file that follows the [template](README_samples_template.md). Generated files (e.g., .exe or .bacpac) and user configuration settings (e.g., .user) should not be committed to GitHub.

## Cloning only a subset of the repo (with sparse checkout)
You can follow the steps below to clone individual files from the sql-server-samples git repo. Note: The following script clones only the files under the **features** and **demos** folders.
```
git clone -n https://github.com/Microsoft/sql-server-samples
cd sql-server-samples
git config core.sparsecheckout true
echo samples/features/*| out-file -append -encoding ascii .git/info/sparse-checkout
echo samples/demos/*| out-file -append -encoding ascii .git/info/sparse-checkout
git checkout
```
For more information about sparse checkout please visit [this](https://stackoverflow.com/questions/23289006/on-windows-git-error-sparse-checkout-leaves-no-entry-on-the-working-directory) stackoverflow thread.

## Code of Conduct
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.

## Questions
Email questions to: sqlserversamples@microsoft.com.
