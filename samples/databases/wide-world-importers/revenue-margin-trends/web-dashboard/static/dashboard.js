
class DashboardManager {
    constructor() {
        this.charts = {};
        this.data = {};
        this.init();
    }

    init() {
        this.loadInitialData();
        this.setupEventListeners();
    }

    setupEventListeners() {
        window.setDateRange = (range) => {
            const endDate = new Date();
            let startDate = new Date();
            
            switch(range) {
                case 'ytd':
                    startDate = new Date(endDate.getFullYear(), 0, 1);
                    break;
                case '12m':
                    startDate = new Date(endDate.getFullYear() - 1, endDate.getMonth(), endDate.getDate());
                    break;
                case '24m':
                    startDate = new Date(endDate.getFullYear() - 2, endDate.getMonth(), endDate.getDate());
                    break;
            }
            
            document.getElementById('startDate').value = startDate.toISOString().split('T')[0];
            document.getElementById('endDate').value = endDate.toISOString().split('T')[0];
            this.refreshDashboard();
        };

        window.refreshDashboard = () => {
            this.loadInitialData();
        };
    }

    async loadInitialData() {
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        
        try {
            const [kpiData, monthlyData, customerData, productData, rollingData] = await Promise.all([
                this.fetchData('/api/kpi-summary', { start_date: startDate, end_date: endDate }),
                this.fetchData('/api/monthly-trends', { start_date: startDate, end_date: endDate }),
                this.fetchData('/api/customer-segments', { start_date: startDate, end_date: endDate }),
                this.fetchData('/api/product-categories', { start_date: startDate, end_date: endDate }),
                this.fetchData('/api/rolling-metrics', { end_date: endDate })
            ]);

            this.data = {
                kpi: kpiData,
                monthly: monthlyData,
                customers: customerData,
                products: productData,
                rolling: rollingData
            };

            this.renderKPICards();
            this.renderMonthlyTrendsChart();
            this.renderCustomerSegmentChart();
            this.renderProductCategoriesChart();
            this.renderRollingMetricsChart();

        } catch (error) {
            console.error('Error loading dashboard data:', error);
            this.showError('Failed to load dashboard data. Please check your database connection.');
        }
    }

    async fetchData(endpoint, params = {}) {
        const url = new URL(endpoint, window.location.origin);
        Object.keys(params).forEach(key => url.searchParams.append(key, params[key]));
        
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    }

    renderKPICards() {
        const kpi = this.data.kpi;
        const kpiContainer = document.getElementById('kpiCards');
        
        kpiContainer.innerHTML = `
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-label">Total Revenue</div>
                    <div class="kpi-value">${this.formatCurrency(kpi.TotalRevenue || 0)}</div>
                    <div class="kpi-change ${(kpi.YoYRevenueGrowth || 0) >= 0 ? 'positive' : 'negative'}">
                        <i class="fas fa-arrow-${(kpi.YoYRevenueGrowth || 0) >= 0 ? 'up' : 'down'}"></i>
                        ${this.formatPercentage(kpi.YoYRevenueGrowth || 0)} YoY
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-label">Total Profit</div>
                    <div class="kpi-value">${this.formatCurrency(kpi.TotalProfit || 0)}</div>
                    <div class="kpi-change ${(kpi.YoYProfitGrowth || 0) >= 0 ? 'positive' : 'negative'}">
                        <i class="fas fa-arrow-${(kpi.YoYProfitGrowth || 0) >= 0 ? 'up' : 'down'}"></i>
                        ${this.formatPercentage(kpi.YoYProfitGrowth || 0)} YoY
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-label">Margin %</div>
                    <div class="kpi-value">${this.formatPercentage(kpi.OverallMarginPercentage || 0)}</div>
                    <div class="kpi-change">
                        <i class="fas fa-chart-pie"></i>
                        Overall Performance
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-label">Transactions</div>
                    <div class="kpi-value">${this.formatNumber(kpi.TotalTransactions || 0)}</div>
                    <div class="kpi-change">
                        <i class="fas fa-users"></i>
                        ${this.formatNumber(kpi.UniqueCustomers || 0)} Customers
                    </div>
                </div>
            </div>
        `;
    }

    renderMonthlyTrendsChart() {
        const ctx = document.getElementById('monthlyTrendsChart').getContext('2d');
        
        if (this.charts.monthlyTrends) {
            this.charts.monthlyTrends.destroy();
        }

        const data = this.data.monthly;
        
        this.charts.monthlyTrends = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.map(d => d.Month),
                datasets: [
                    {
                        label: 'Revenue (Excl. Tax)',
                        data: data.map(d => d.RevenueExcludingTax),
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Profit',
                        data: data.map(d => d.Profit),
                        borderColor: '#e74c3c',
                        backgroundColor: 'rgba(231, 76, 60, 0.1)',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Margin %',
                        data: data.map(d => d.MarginPercentage),
                        borderColor: '#f39c12',
                        backgroundColor: 'rgba(243, 156, 18, 0.1)',
                        yAxisID: 'y1',
                        type: 'line'
                    }
                ]
            },
            options: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        ticks: {
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        ticks: {
                            callback: function(value) {
                                return value.toFixed(1) + '%';
                            }
                        },
                        grid: {
                            drawOnChartArea: false,
                        },
                    }
                },
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.dataset.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                if (context.dataset.yAxisID === 'y1') {
                                    label += context.parsed.y.toFixed(2) + '%';
                                } else {
                                    label += '$' + context.parsed.y.toLocaleString();
                                }
                                return label;
                            }
                        }
                    }
                }
            }
        });
    }

    renderCustomerSegmentChart() {
        const ctx = document.getElementById('customerSegmentChart').getContext('2d');
        
        if (this.charts.customerSegment) {
            this.charts.customerSegment.destroy();
        }

        const data = this.data.customers;
        
        this.charts.customerSegment = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.map(d => d.CustomerSegment),
                datasets: [{
                    data: data.map(d => d.SegmentRevenueExcludingTax),
                    backgroundColor: [
                        '#3498db',
                        '#e74c3c',
                        '#f39c12',
                        '#27ae60',
                        '#9b59b6',
                        '#1abc9c'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const value = context.parsed;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return context.label + ': $' + value.toLocaleString() + ' (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
    }

    renderProductCategoriesChart() {
        const ctx = document.getElementById('productCategoriesChart').getContext('2d');
        
        if (this.charts.productCategories) {
            this.charts.productCategories.destroy();
        }

        const data = this.data.products.slice(0, 8); // Top 8 products
        
        this.charts.productCategories = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(d => `${d.ProductBrand} - ${d.ProductColor}`),
                datasets: [
                    {
                        label: 'Revenue',
                        data: data.map(d => d.ProductRevenueExcludingTax),
                        backgroundColor: '#3498db',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Margin %',
                        data: data.map(d => d.ProductMarginPercentage),
                        backgroundColor: '#f39c12',
                        yAxisID: 'y1',
                        type: 'line'
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    x: {
                        ticks: {
                            maxRotation: 45
                        }
                    },
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        ticks: {
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        ticks: {
                            callback: function(value) {
                                return value.toFixed(1) + '%';
                            }
                        },
                        grid: {
                            drawOnChartArea: false,
                        },
                    }
                }
            }
        });
    }

    renderRollingMetricsChart() {
        const ctx = document.getElementById('rollingMetricsChart').getContext('2d');
        
        if (this.charts.rollingMetrics) {
            this.charts.rollingMetrics.destroy();
        }

        const data = this.data.rolling;
        
        this.charts.rollingMetrics = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.map(d => new Date(d.ReportDate).toLocaleDateString()),
                datasets: [
                    {
                        label: 'Rolling 12M Revenue',
                        data: data.map(d => d.Rolling12MRevenue),
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Rolling 12M Margin %',
                        data: data.map(d => d.Rolling12MMarginPercentage),
                        borderColor: '#f39c12',
                        backgroundColor: 'rgba(243, 156, 18, 0.1)',
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        ticks: {
                            callback: function(value) {
                                return '$' + (value / 1000000).toFixed(1) + 'M';
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        ticks: {
                            callback: function(value) {
                                return value.toFixed(1) + '%';
                            }
                        },
                        grid: {
                            drawOnChartArea: false,
                        },
                    }
                }
            }
        });
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(value);
    }

    formatPercentage(value) {
        return new Intl.NumberFormat('en-US', {
            style: 'percent',
            minimumFractionDigits: 1,
            maximumFractionDigits: 1
        }).format(value / 100);
    }

    formatNumber(value) {
        return new Intl.NumberFormat('en-US').format(value);
    }

    showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'alert alert-danger';
        errorDiv.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${message}`;
        document.querySelector('.container-fluid').prepend(errorDiv);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    new DashboardManager();
});
