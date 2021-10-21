<template>
  <a-card :bordered="false">
    <h2>使用情況摘要</h2>
    <h2> </h2>
    <h4>選擇一段時間來查詢其用量：</h4>
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :span="3" >
            <a-form-item label="">
              <j-date v-model="queryParam.startTime" placeholder="請選擇開始時間" date-format="YYYY-MM-DD"  ></j-date>
            </a-form-item>
          </a-col>
          <a-col :span="3">
            <a-form-item label="到">
              <j-date v-model="queryParam.endTime" placeholder="請選擇結束時間" date-format="YYYY-MM-DD"  ></j-date>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <div style="margin-bottom: 16px;">
      <a-row :gutter="24">
        <a-col :span="3" :style="{textAlign:'right'}">
          <h4>運行中的實例：</h4>
          <h4>啟用的內存：</h4>
          <h4>週期內VCPU-小時數：</h4>
          <h4>週期內磁盤GB-小時數：</h4>
          <h4>此週期內的 RAM-小時數：</h4>
        </a-col>
        <a-col :span="2">
          <h4>{{ showData.server_usages }}</h4>
          <h4>{{ showData.ramText }}</h4>
          <h4>{{ showData.total_vcpus_usage }}</h4>
          <h4>{{ showData.total_local_gb_usage }}</h4>
          <h4>{{ showData.total_memory_mb_usage }}</h4>
        </a-col>
      </a-row>
    </div>

    <!-- table區域-begin -->
    <div>
      <!--<div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
       <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>-->

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="instanceName" slot-scope="text, record">
          <a @click="handleRouter(record)">{{ text }}</a>
        </span>


      </a-table>
    </div>

  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import moment from 'moment'
  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'

  export default {
    name: 'OsInstanceList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      moment
    },
    props:{
      selectProjectId:{
        type: String,
        default: ''
      }
    },
    data () {
      return {
        description: '申請明細檔管理頁面',
        // 表頭
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'實例名稱',
            align:"center",
            dataIndex: 'name',
            scopedSlots: { customRender: 'name' }
          },
          {
            title:'VCPUs',
            align:"center",
            dataIndex: 'vcpus'
          },
          {
            title:'Disk',
            align:"center",
            dataIndex: 'local_gb',
            customRender:function (text) {
              return text+"GB"
            }
          },
          {
            title:'RAM',
            align:"center",
            dataIndex: 'memory_mb',
            customRender:function (text) {
              if(text<1024){
                return text+"MB"
              }else{
                return text/1024+"GB"
              }
              return text+"MB"
            }
          },
          {
            title:'開始時間',
            align:"center",
            dataIndex: 'started_at'
          },
        ],
        url: {
          list: "/openstack/projectSurvey/list",
          delete: "/openstack/osInstance/delete",
          deleteBatch: "/openstack/osInstance/deleteBatch",
          exportXlsUrl: "/openstack/osInstance/exportXls",
          importExcelUrl: "openstack/osInstance/importExcel",

        },
        dictOptions:{},
        superFieldList:[],
        showData:{},
      }
    },
    created() {
     /* this.queryParam.endTime = moment(today).format('YYYY-MM-DD');
      let date = today.getDate();
      date = date - 1;
      this.queryParam.startTime = moment(new Date().setDate(date)).format('YYYY-MM-DD');*/

      this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'instanceName',text:'實例名稱',dictCode:''})
        fieldList.push({type:'string',value:'options',text:'申請狀態',dictCode:''})
        fieldList.push({type:'string',value:'status',text:'狀態',dictCode:''})
        fieldList.push({type:'string',value:'represent',text:'描述',dictCode:''})
        fieldList.push({type:'string',value:'imgId',text:'鏡像id',dictCode:''})
        fieldList.push({type:'string',value:'isDelete',text:'刪除實例時是否刪除卷',dictCode:''})
        fieldList.push({type:'string',value:'flavorId',text:'實例類型id',dictCode:''})
        fieldList.push({type:'string',value:'runStatus',text:'運行狀態',dictCode:''})
        fieldList.push({type:'string',value:'securityName',text:'安全組',dictCode:''})
        fieldList.push({type:'string',value:'networkId',text:'網絡',dictCode:''})
        this.superFieldList = fieldList
      },
      loadData(arg) {
        if(!this.url.list){
          this.$message.error("請設置url.list屬性!")
          return
        }
        //加載數據 若傳入參數1則加載第一頁的內容
        if (arg === 1) {
          this.ipagination.current = 1;
        }
        if(!(this.queryParam.startTime>''&&this.queryParam.endTime>'')){
          let today = new Date();
          let date = today.getDate();
          date = date - 1;
          this.queryParam = {
            endTime: moment(today).format('YYYY-MM-DD'),
            startTime:   moment(new Date().setDate(date)).format('YYYY-MM-DD')
          }
        }
        let params = this.getQueryParams();//查詢條件
        params.projectId = this.selectProjectId;
        this.loading = true;
        getAction(this.url.list, params).then((res) => {
          if (res.success) {
            debugger;
            //update-begin---author:zhangyafei    Date:20201118  for：適配不分頁的數據列表------------
            this.dataSource = res.result.records||res.result.server_usages;
            let ram = 0;
            if(this.dataSource){
              this.dataSource.forEach((r)=>{
                if(r.state=='active')
                  ram = ram + r.memory_mb;
              })
              if(ram<1024){
                this.showData.ramText = ram+"MB";
              }else{
                this.showData.ramText = ram/1024 +"GB";
              }

              this.showData.server_usages = this.dataSource.length;
              this.showData.total_vcpus_usage = res.result.total_vcpus_usage.toFixed(2)
              this.showData.total_local_gb_usage = res.result.total_local_gb_usage.toFixed(2)
              this.showData.total_memory_mb_usage = res.result.total_memory_mb_usage.toFixed(2)

            }else{
              this.showData ={
                server_usages:'',
                ramText:'',
                total_vcpus_usage:'',
                total_local_gb_usage:'',
                total_memory_mb_usage:''
              }
            }


            if(res.result.total)
            {
              this.ipagination.total = res.result.total;
            }else{
              this.ipagination.total = 0;
            }
            //update-end---author:zhangyafei    Date:20201118  for：適配不分頁的數據列表------------
          }else{
            this.$message.warning(res.message)
          }
        }).finally(() => {
          this.loading = false
        })
      },

    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>