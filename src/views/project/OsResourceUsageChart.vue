<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" >
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24" >
            <a-form-model-item label="專案名稱"  >
              <a-select v-model="queryParam.projectId"  @change="getUrl(barType,{})" placeholder="請選擇專案" >
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <!--<a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
            </span>
          </a-col>-->
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->
    <a-tabs defaultActiveKey="1" @change="callback">
      <a-tab-pane tab="柱狀圖" key="1">
        <a-row>
          <a-col :span="10">
            <a-radio-group :value="barType" @change="statisticst">
              <a-radio-button value="date">按天統計</a-radio-button>
              <a-radio-button value="month">按月統計</a-radio-button>
              <a-radio-button value="year">按年統計</a-radio-button>
            </a-radio-group>
          </a-col>
          <a-col :span="14">
            <a-form v-if="barType === 'month' && true" layout="inline" style="margin-top: -4px">
              <a-form-item label="月份區間">
                <a-range-picker
                  :placeholder="['開始月份', '結束月份']"
                  format="YYYY-MM"
                  :value="barValue"
                  :mode="barDate"
                  @panelChange="handleBarDate"/>
              </a-form-item>
              <a-button style="margin-top: 2px" type="primary" icon="search" @click="queryDatebar">查詢</a-button>
              <a-button style="margin-top: 2px;margin-left: 8px" type="primary" icon="reload" @click="searchReset">重置</a-button>
            </a-form>
          </a-col>
        </a-row>
        <a-row>
          <a-col :span="20">
            <bar-multid  class="statistic" title="多列柱狀圖" :height="300" :fields="fields" :dataSource="barMultidDataSource"/>
          </a-col>
        </a-row>
        <a-row>
          <a-col :span="8">
            <bar class="statistic" title="周期内CPU-小時數" :dataSource="cpuSource" :color="['item','red']" :height="200" :style="{width:'80%'}"/>
          </a-col>
          <a-col :span="8">
            <bar class="statistic" title="周期内硬碟GB-小時數" :dataSource="diskSource" :height="200" :style="{width:'80%'}"/>
          </a-col>
          <a-col :span="8">
            <bar class="statistic" title="周期内RAM-小時數" :dataSource="ramSource" :height="200" :style="{width:'80%'}"/>
          </a-col>
        </a-row>
      </a-tab-pane>

      <a-tab-pane tab="折綫圖" key="2">
        <a-row>
          <a-col :span="10">
            <a-radio-group :value="barType" @change="statisticst">
              <a-radio-button value="date">按天統計</a-radio-button>
              <a-radio-button value="month">按月統計</a-radio-button>
              <a-radio-button value="year">按年統計</a-radio-button>
            </a-radio-group>
          </a-col>
          <a-col :span="14">
            <a-form v-if="barType === 'month' && true" layout="inline" style="margin-top: -4px">
              <a-form-item label="月份區間">
                <a-range-picker
                  :placeholder="['開始月份', '結束月份']"
                  format="YYYY-MM"
                  :value="barValue"
                  :mode="barDate"
                  @panelChange="handleLineDate"/>
              </a-form-item>
              <a-button style="margin-top: 2px" type="primary" icon="search" @click="queryDatebar">查詢</a-button>
              <a-button style="margin-top: 2px;margin-left: 8px" type="primary" icon="reload" @click="searchReset">重置</a-button>
            </a-form>
          </a-col>
        </a-row>
        <a-row>
          <a-col :span="24">
            <line-chart-multid  class="statistic" title="多行折綫圖" :height="300" :fields="linefields" :dataSource="lineMultidDataSource"/>
          </a-col>
        </a-row>
        <a-row>
          <a-col :span="8">
            <line-chart-multid class="statistic" title="周期内CPU-小時數" :dataSource="lineCpuSource" :fields="lineCpufields" :height="256" />
          </a-col>
          <a-col :span="8">
            <line-chart-multid class="statistic" title="周期内硬碟GB-小時數" :dataSource="lineDiskSource" :fields="lineDiskfields" :height="256" />
          </a-col>
          <a-col :span="8">
            <line-chart-multid class="statistic" title="周期内RAM-小時數" :dataSource="lineRamSource" :fields="lineRamfields" :height="256" />
          </a-col>
        </a-row>
      </a-tab-pane>
    </a-tabs>


  </a-card>
</template>

<script>
  import Bar from '@/components/chart/Bar'
  import Pie from '@/components/chart/Pie'
  import ACol from 'ant-design-vue/es/grid/Col'
  import BarMultid from '@/components/chart/BarMultid'
  import LineChartMultid from '../../components/chart/LineChartMultid'
  import { httpAction,getAction } from '@/api/manage'

  export default {
    name: 'OsResourceUsageChart',
    components: {
      ACol,
      Bar,
      Pie,
      BarMultid,
      LineChartMultid
    },
    data() {
      return {
        description: '檔案統計頁面',
        // 查詢條件
        queryParam: {},
        // 數據集
        cpuSource: [],
        // 數據集
        diskSource: [],
        // 數據集
        ramSource: [],
        // 數據集
        countSource: [],
        fields: [],
        barMultidDataSource: [],

        lineCpufields:['vcpu'],
        lineCpuSource:[],

        lineDiskfields:['disk'],
        lineDiskSource:[],

        lineRamfields:['ram'],
        lineRamSource:[],

        linefields:['vcpu','disk','ram'],
        lineMultidDataSource:[],

        // 柱狀圖
        barType: 'date',
        barDate: ['month', 'month'],
        barValue: [],
        // 餅狀圖
        pieType: 'year',
        pieDate: ['month', 'month'],
        pieValue: [],
        // 統計圖類型
        tabStatus:"bar",
        url: {
          getProject: "/os/osApply/getProject",
          getYearCountInfo: "/openstack/osResourceUsage/getYearCountInfo",
          getMonthCountInfo:"/openstack/osResourceUsage/getMonthCountInfo",
          getDateCountInfo:"/openstack/osResourceUsage/getDateCountInfo",
        },
        projects:[],
      }
    },
    created() {
      this.loadProjects()
      /*let url = this.url.getDateCountInfo;
      this.loadDate(url,'date',{});*/
    },
    methods: {
      loadProjects(){
        let method = "post";
        let httpurl = this.url.getProject;
        let that = this;
        httpAction(httpurl, { },method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
            if(result.length>0){
              let url = that.url.getDateCountInfo
              that.loadDate(url,'date',{})
            }
          }
        })
      },
      loadDate(url,type,param) {
        if(!this.queryParam.projectId){
          this.queryParam = {
            projectId : this.projects[0].value
          }
        }
        param.projectId = this.queryParam.projectId;
        getAction(url,param,'get').then((res) => {
          if (res.success) {
            this.countSource = [];

            //柱狀數據集
            this.cpuSource = [];
            this.diskSource = [];
            this.ramSource = [];
            this.fields = [];
            this.barMultidDataSource = [];

            //折綫數據集
            this.lineCpuSource = [];
            this.lineDiskSource = [];
            this.lineRamSource = [];
            this.lineMultidDataSource = [];

            if(type === 'year'){
              this.getYearCountSource(res.result);
            }
            if(type === 'month'){
              this.getMonthCountSource(res.result);
            }
            if(type === 'date'){
              this.getDateCountSource(res.result);
            }
          }else{
            var that=this;
            that.$message.warning(res.message);
          }
        })
      },
      getYearCountSource(data){
        if(this.tabStatus === "bar") {
          let cpuMap = { type: 'vcpu' }
          let diskMap = { type: 'disk' }
          let ramMap = { type: 'ram' }

          data.forEach((r) => {
            cpuMap[r.years] = r.totalVcpusUsage;
            diskMap[r.years] = r.totalLocalGbUsage;
            ramMap[r.years] = (r.totalMemoryMbUsage / 1024).toFixed(1);
            this.fields.push(r.years);
            this.cpuSource.push({
              x: r.years,
              y: r.totalVcpusUsage
            })

            this.diskSource.push({
              x: r.years,
              y: r.totalLocalGbUsage
            })

            this.ramSource.push({
              x: r.years,
              y: (r.totalMemoryMbUsage / 1024).toFixed(1)
            })
          })

          this.barMultidDataSource.push(cpuMap)
          this.barMultidDataSource.push(diskMap)
          this.barMultidDataSource.push(ramMap)
        }else if(this.tabStatus === "line") {

          data.forEach((r) => {

            this.lineMultidDataSource.push({
              type:r.years,
              vcpu:r.totalVcpusUsage,
              disk:r.totalLocalGbUsage,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });

            this.lineCpuSource.push({
              type:r.years,
              vcpu:r.totalVcpusUsage
            });

            this.lineDiskSource.push({
              type:r.years,
              disk:r.totalLocalGbUsage
            });

            this.lineRamSource.push({
              type:r.years,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });
          })
        }
      },
      getMonthCountSource(data){
        if(this.tabStatus === "bar") {
          let cpuMap = { type: 'vcpu' }
          let diskMap = { type: 'disk' }
          let ramMap = { type: 'ram' }

          data.forEach((r) => {
            cpuMap[r.mon] = r.totalVcpusUsage;
            diskMap[r.mon] = r.totalLocalGbUsage;
            ramMap[r.mon] = (r.totalMemoryMbUsage / 1024).toFixed(1);
            this.fields.push(r.mon);
            this.cpuSource.push({
              x: r.mon,
              y: r.totalVcpusUsage
            })

            this.diskSource.push({
              x: r.mon,
              y: r.totalLocalGbUsage
            })

            this.ramSource.push({
              x: r.mon,
              y: (r.totalMemoryMbUsage / 1024).toFixed(1)
            })
          })

          this.barMultidDataSource.push(cpuMap)
          this.barMultidDataSource.push(diskMap)
          this.barMultidDataSource.push(ramMap)
        }else if(this.tabStatus === "line") {

          data.forEach((r) => {

            this.lineMultidDataSource.push({
              type:r.mon,
              vcpu:r.totalVcpusUsage,
              disk:r.totalLocalGbUsage,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });

            this.lineCpuSource.push({
              type:r.mon,
              vcpu:r.totalVcpusUsage
            });

            this.lineDiskSource.push({
              type:r.mon,
              disk:r.totalLocalGbUsage
            });

            this.lineRamSource.push({
              type:r.mon,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });
          })
        }
      },
      getDateCountSource(data){
        if(this.tabStatus === "bar") {
          let cpuMap = { type: 'vcpu' }
          let diskMap = { type: 'disk' }
          let ramMap = { type: 'ram' }

          data.forEach((r) => {
            cpuMap[r.usageDate] = r.totalVcpusUsage;
            diskMap[r.usageDate] = r.totalLocalGbUsage;
            ramMap[r.usageDate] = (r.totalMemoryMbUsage / 1024).toFixed(1);
            this.fields.push(r.usageDate);
            this.cpuSource.push({
              x: r.usageDate,
              y: r.totalVcpusUsage
            })

            this.diskSource.push({
              x: r.usageDate,
              y: r.totalLocalGbUsage
            })

            this.ramSource.push({
              x: r.usageDate,
              y: (r.totalMemoryMbUsage / 1024).toFixed(1)
            })
          })

          this.barMultidDataSource.push(cpuMap)
          this.barMultidDataSource.push(diskMap)
          this.barMultidDataSource.push(ramMap)
        }else if(this.tabStatus === "line") {

          data.forEach((r) => {

            this.lineMultidDataSource.push({
              type:r.usageDate,
              vcpu:r.totalVcpusUsage,
              disk:r.totalLocalGbUsage,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });

            this.lineCpuSource.push({
              type:r.usageDate,
              vcpu:r.totalVcpusUsage
            });

            this.lineDiskSource.push({
              type:r.usageDate,
              disk:r.totalLocalGbUsage
            });

            this.lineRamSource.push({
              type:r.usageDate,
              ram:(r.totalMemoryMbUsage / 1024).toFixed(1)
            });
          })
        }
      },
      // 選擇統計圖類別
      callback(key) {
        if(key === "1"){
          this.tabStatus = "bar";
          this.queryDatebar();
        }else if(key === "2"){
          this.tabStatus = "line";
          this.queryDatebar();
        }else{
          this.tabStatus = "pie";
          this.queryDatepie();
        }
      },
      // 選擇統計類別
      statisticst(e) {
        if(this.tabStatus === "pie"){
          this.pieType = e.target.value;
          this.queryDatepie();
        }else if(this.tabStatus === "line"){
          this.barType = e.target.value;
          this.queryDatebar();
        }else{
          this.barType = e.target.value;
          this.queryDatebar();
        }
      },
      // 按月份查詢
      queryDatebar(){
        if(this.barValue.length>0){
          this.getUrl(this.barType,{startTime:this.barValue[0]._d,endTime:this.barValue[1]._d});
        }else{
          this.getUrl(this.barType,{});
        }
      },
      queryDateline(){
        if(this.barValue.length>0){
          this.getUrl(this.barType,{startTime:this.barValue[0]._d,endTime:this.barValue[1]._d});
        }else{
          this.getUrl(this.barType,{});
        }
      },
      queryDatepie(){
        if(this.pieValue.length>0){
          this.getUrl(this.pieType,{startTime:this.pieValue[0]._d,endTime:this.pieValue[1]._d});
        }else{
          this.getUrl(this.pieType,{});
        }
      },
      searchReset(){
        console.log(this.tabStatus);
        if(this.tabStatus === "pie"){
          this.pieValue = [];
        }else{
          this.barValue = [];
        }
        this.getUrl(this.barType,{});
      },
      // 選擇請求url
      getUrl(type,param){
        let url = "";
        if(type === 'year'){
          url = this.url.getYearCountInfo;
        }
        if(type === 'month'){
          url = this.url.getMonthCountInfo;
        }
        if(type === 'date'){
          url = this.url.getDateCountInfo;
        }
        this.loadDate(url,type,param);
      },
      // 選擇月份日期
      handleBarDate(value, mode) {
        this.barValue = value
        this.barDate = [
          mode[0] === 'date' ? 'month' : mode[0],
          mode[1] === 'date' ? 'month' : mode[1]
        ]
      },
      handleLineDate(value, mode) {
        this.barValue = value
        this.barDate = [
          mode[0] === 'date' ? 'month' : mode[0],
          mode[1] === 'date' ? 'month' : mode[1]
        ]
      },
      handlePieDate(value, mode) {
        this.pieValue = value
        this.pieDate = [
          mode[0] === 'date' ? 'month' : mode[0],
          mode[1] === 'date' ? 'month' : mode[1]
        ]
      },
    }
  }
</script>
<style scoped>
  .ant-card-body .table-operator {
    margin-bottom: 18px;
  }

  .ant-table-tbody .ant-table-row td {
    padding-top: 15px;
    padding-bottom: 15px;
  }

  .anty-row-operator button {
    margin: 0 5px
  }

  .ant-btn-danger {
    background-color: #ffffff
  }

  .ant-modal-cust-warp {
    height: 100%
  }

  .ant-modal-cust-warp .ant-modal-body {
    height: calc(100% - 110px) !important;
    overflow-y: auto
  }

  .ant-modal-cust-warp .ant-modal-content {
    height: 90% !important;
    overflow-y: hidden
  }

  .statistic {
    padding: 0px !important;
    margin-top: 50px;
  }

  .statistic h4 {
    margin-bottom: 20px;
    text-align: center !important;
    font-size: 24px !important;;
  }

  .statistic #canvas_1 {
    width: 100% !important;
  }
</style>