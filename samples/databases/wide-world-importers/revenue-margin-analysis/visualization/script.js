
class RevenueMarginDashboard {
    constructor() {
        this.data = [];
        this.charts = {};
        this.currentChartType = 'line';
        this.currentDataView = 'absolute';
        
        this.init();
    }

    async init() {
        try {
            await this.loadData();
            this.setupEventListeners();
            this.updateKPIs();
            this.createCharts();
            this.populateDataTable();
            this.updateLastUpdated();
        } catch (error) {
            console.error('Failed to initialize dashboard:', error);
            this.showError('Failed to load data. Please check the console for details.');
        }
    }

    async loadData() {
        try {
            const response = await fetch('data.json');
            if (response.ok) {
                this.data = await response.json();
                console.log('Loaded data from local file:', this.data.length, 'records');
            } else {
                this.data = this.generateSampleData();
                console.log('Using generated sample data:', this.data.length, 'records');
            }
        } catch (error) {
            console.warn('Could not load data file, using sample data:', error);
            this.data = this.generateSampleData();
        }
    }

    generateSampleData() {
        const sampleData = [];
        const baseDate = new Date();
        baseDate.setDate(1); // First day of current month
        
        for (let i = 11; i >= 0; i--) {
            const monthDate = new Date(baseDate);
            monthDate.setMonth(monthDate.getMonth() - i);
            
            const monthYear = monthDate.toLocaleDateString('en-US', { 
                month: 'short', 
                year: 'numeric' 
            });
            
            const baseRevenue = 850000 + (i * 15000);
            const seasonalFactor = 1 + (0.2 * (i % 4 === 0 ? 1 : 0));
            const noiseFactor = 1 + (Math.random() - 0.5) * 0.2;
            
            const totalRevenue = baseRevenue * seasonalFactor * noiseFactor;
            const totalMargin = totalRevenue * (0.15 + Math.random() * 0.1);
            const marginPercentage = (totalMargin / totalRevenue) * 100;
            
            sampleData.push({
                month_year: monthYear,
                year_num: monthDate.getFullYear(),
                month_num: monthDate.getMonth() + 1,
                total_revenue: Math.round(totalRevenue * 100) / 100,
                revenue_excluding_tax: Math.round(totalRevenue * 0.9 * 100) / 100,
                total_margin: Math.round(totalMargin * 100) / 100,
                total_tax: Math.round(totalRevenue * 0.1 * 100) / 100,
                transaction_count: Math.floor(1200 + Math.random() * 600),
                avg_transaction_value: Math.round((totalRevenue / (1200 + Math.random() * 600)) * 100) / 100,
                margin_percentage: Math.round(marginPercentage * 100) / 100,
                revenue_growth_pct: i > 0 ? Math.round((Math.random() - 0.4) * 20 * 100) / 100 : null,
                margin_growth_pct: i > 0 ? Math.round((Math.random() - 0.3) * 15 * 100) / 100 : null
            });
        }
        
        return sampleData;
    }

    setupEventListeners() {
        document.getElementById('chartType').addEventListener('change', (e) => {
            this.currentChartType = e.target.value;
            this.updateCharts();
        });

        document.getElementById('dataView').addEventListener('change', (e) => {
            this.currentDataView = e.target.value;
            this.updateCharts();
        });

        document.getElementById('exportData').addEventListener('click', () => {
            this.exportData();
        });

        document.getElementById('refreshData').addEventListener('click', () => {
            this.refreshFromSupabase();
        });
    }

    updateKPIs() {
        const totalRevenue = this.data.reduce((sum, item) => sum + item.total_revenue, 0);
        const totalMargin = this.data.reduce((sum, item) => sum + item.total_margin, 0);
        const avgMarginPct = this.data.reduce((sum, item) => sum + item.margin_percentage, 0) / this.data.length;
        const totalTransactions = this.data.reduce((sum, item) => sum + item.transaction_count, 0);

        const lastMonth = this.data[this.data.length - 1];
        const prevMonth = this.data[this.data.length - 2];

        const revenueChange = prevMonth ? 
            ((lastMonth.total_revenue - prevMonth.total_revenue) / prevMonth.total_revenue) * 100 : 0;
        const marginChange = prevMonth ? 
            ((lastMonth.total_margin - prevMonth.total_margin) / prevMonth.total_margin) * 100 : 0;
        const marginPctChange = prevMonth ? 
            lastMonth.margin_percentage - prevMonth.margin_percentage : 0;
        const transactionChange = prevMonth ? 
            ((lastMonth.transaction_count - prevMonth.transaction_count) / prevMonth.transaction_count) * 100 : 0;

        document.getElementById('totalRevenue').textContent = this.formatCurrency(totalRevenue);
        document.getElementById('totalMargin').textContent = this.formatCurrency(totalMargin);
        document.getElementById('avgMarginPct').textContent = avgMarginPct.toFixed(1) + '%';
        document.getElementById('totalTransactions').textContent = totalTransactions.toLocaleString();

        this.updateKPIChange('revenueChange', revenueChange);
        this.updateKPIChange('marginChange', marginChange);
        this.updateKPIChange('marginPctChange', marginPctChange);
        this.updateKPIChange('transactionChange', transactionChange);
    }

    updateKPIChange(elementId, value) {
        const element = document.getElementById(elementId);
        const formattedValue = elementId === 'marginPctChange' ? 
            (value > 0 ? '+' : '') + value.toFixed(1) + 'pp' : 
            (value > 0 ? '+' : '') + value.toFixed(1) + '%';
        
        element.textContent = formattedValue;
        element.className = 'kpi-change ' + (value > 0 ? 'positive' : value < 0 ? 'negative' : 'neutral');
    }

    createCharts() {
        this.createMainChart();
        this.createGrowthChart();
    }

    createMainChart() {
        const ctx = document.getElementById('mainChart').getContext('2d');
        
        if (this.charts.main) {
            this.charts.main.destroy();
        }

        const labels = this.data.map(item => item.month_year);
        const revenueData = this.data.map(item => item.total_revenue);
        const marginData = this.data.map(item => item.total_margin);

        const config = {
            type: this.currentChartType === 'combined' ? 'line' : this.currentChartType,
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Total Revenue',
                        data: revenueData,
                        borderColor: '#3498db',
                        backgroundColor: this.currentChartType === 'bar' ? 'rgba(52, 152, 219, 0.7)' : 'rgba(52, 152, 219, 0.1)',
                        borderWidth: 3,
                        fill: this.currentChartType === 'line',
                        tension: 0.4
                    },
                    {
                        label: 'Total Margin',
                        data: marginData,
                        borderColor: '#27ae60',
                        backgroundColor: this.currentChartType === 'bar' ? 'rgba(39, 174, 96, 0.7)' : 'rgba(39, 174, 96, 0.1)',
                        borderWidth: 3,
                        fill: this.currentChartType === 'line',
                        tension: 0.4,
                        yAxisID: this.currentChartType === 'combined' ? 'y1' : 'y'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Revenue and Margin Trends (12 Months)',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        display: true,
                        position: 'top'
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            label: (context) => {
                                const label = context.dataset.label;
                                const value = this.formatCurrency(context.parsed.y);
                                return `${label}: ${value}`;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Month'
                        }
                    },
                    y: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Amount ($)'
                        },
                        ticks: {
                            callback: (value) => this.formatCurrency(value, true)
                        }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        };

        if (this.currentChartType === 'combined') {
            config.options.scales.y1 = {
                type: 'linear',
                display: true,
                position: 'right',
                title: {
                    display: true,
                    text: 'Margin ($)'
                },
                ticks: {
                    callback: (value) => this.formatCurrency(value, true)
                },
                grid: {
                    drawOnChartArea: false,
                }
            };
        }

        this.charts.main = new Chart(ctx, config);
    }

    createGrowthChart() {
        const ctx = document.getElementById('growthChart').getContext('2d');
        
        if (this.charts.growth) {
            this.charts.growth.destroy();
        }

        const labels = this.data.filter(item => item.revenue_growth_pct !== null).map(item => item.month_year);
        const revenueGrowthData = this.data.filter(item => item.revenue_growth_pct !== null).map(item => item.revenue_growth_pct);
        const marginGrowthData = this.data.filter(item => item.margin_growth_pct !== null).map(item => item.margin_growth_pct);

        this.charts.growth = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Revenue Growth %',
                        data: revenueGrowthData,
                        backgroundColor: revenueGrowthData.map(val => val >= 0 ? 'rgba(39, 174, 96, 0.7)' : 'rgba(231, 76, 60, 0.7)'),
                        borderColor: revenueGrowthData.map(val => val >= 0 ? '#27ae60' : '#e74c3c'),
                        borderWidth: 2
                    },
                    {
                        label: 'Margin Growth %',
                        data: marginGrowthData,
                        backgroundColor: marginGrowthData.map(val => val >= 0 ? 'rgba(52, 152, 219, 0.7)' : 'rgba(230, 126, 34, 0.7)'),
                        borderColor: marginGrowthData.map(val => val >= 0 ? '#3498db' : '#e67e22'),
                        borderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Month-over-Month Growth Rates',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        display: true,
                        position: 'top'
                    },
                    tooltip: {
                        callbacks: {
                            label: (context) => {
                                const label = context.dataset.label;
                                const value = context.parsed.y.toFixed(1);
                                return `${label}: ${value}%`;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Month'
                        }
                    },
                    y: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Growth Rate (%)'
                        },
                        ticks: {
                            callback: (value) => value + '%'
                        }
                    }
                }
            }
        });
    }

    updateCharts() {
        this.createMainChart();
    }

    populateDataTable() {
        const tbody = document.getElementById('dataTableBody');
        tbody.innerHTML = '';

        this.data.forEach(item => {
            const row = tbody.insertRow();
            row.innerHTML = `
                <td>${item.month_year}</td>
                <td>${this.formatCurrency(item.total_revenue)}</td>
                <td>${this.formatCurrency(item.total_margin)}</td>
                <td>${item.margin_percentage.toFixed(1)}%</td>
                <td class="${this.getGrowthClass(item.revenue_growth_pct)}">
                    ${item.revenue_growth_pct ? item.revenue_growth_pct.toFixed(1) + '%' : 'N/A'}
                </td>
                <td>${item.transaction_count.toLocaleString()}</td>
                <td>${this.formatCurrency(item.avg_transaction_value)}</td>
            `;
        });
    }

    getGrowthClass(value) {
        if (value === null || value === undefined) return '';
        return value > 0 ? 'positive' : value < 0 ? 'negative' : 'neutral';
    }

    formatCurrency(amount, short = false) {
        if (short && amount >= 1000000) {
            return '$' + (amount / 1000000).toFixed(1) + 'M';
        } else if (short && amount >= 1000) {
            return '$' + (amount / 1000).toFixed(0) + 'K';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    }

    exportData() {
        const headers = [
            'Month', 'Total Revenue', 'Total Margin', 'Margin %', 
            'Revenue Growth %', 'Margin Growth %', 'Transactions', 'Avg Transaction'
        ];
        
        const csvContent = [
            headers.join(','),
            ...this.data.map(item => [
                item.month_year,
                item.total_revenue,
                item.total_margin,
                item.margin_percentage,
                item.revenue_growth_pct || '',
                item.margin_growth_pct || '',
                item.transaction_count,
                item.avg_transaction_value
            ].join(','))
        ].join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'revenue_margin_trends.csv';
        a.click();
        window.URL.revokeObjectURL(url);

        const jsonContent = JSON.stringify(this.data, null, 2);
        const jsonBlob = new Blob([jsonContent], { type: 'application/json' });
        const jsonUrl = window.URL.createObjectURL(jsonBlob);
        const jsonA = document.createElement('a');
        jsonA.href = jsonUrl;
        jsonA.download = 'revenue_margin_trends.json';
        jsonA.click();
        window.URL.revokeObjectURL(jsonUrl);
    }

    async refreshFromSupabase() {
        const button = document.getElementById('refreshData');
        const originalText = button.textContent;
        button.innerHTML = '<span class="loading"></span> Refreshing...';
        button.disabled = true;

        try {
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            this.data = this.generateSampleData();
            
            this.updateKPIs();
            this.updateCharts();
            this.populateDataTable();
            this.updateLastUpdated();
            
            this.showSuccess('Data refreshed successfully from Supabase!');
        } catch (error) {
            console.error('Failed to refresh data:', error);
            this.showError('Failed to refresh data from Supabase.');
        } finally {
            button.textContent = originalText;
            button.disabled = false;
        }
    }

    updateLastUpdated() {
        document.getElementById('lastUpdated').textContent = new Date().toLocaleString();
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 6px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            background: ${type === 'success' ? '#27ae60' : '#e74c3c'};
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 5000);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new RevenueMarginDashboard();
});
