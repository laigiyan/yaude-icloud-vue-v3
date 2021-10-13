<template>
  <a-card :bordered="false">
    <h2>使用情況摘要</h2>
    <h2> </h2>
    <h4>选择一段时间来查询其用量：</h4>
    <!-- 查询区域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :span="3" >
            <a-form-item label="">
              <j-date v-model="queryParam.startTime" placeholder="请选择开始时间" date-format="YYYY-MM-DD"  ></j-date>
            </a-form-item>
          </a-col>
          <a-col :span="3">
            <a-form-item label="到">
              <j-date v-model="queryParam.endTime" placeholder="请选择結束时间" date-format="YYYY-MM-DD"  ></j-date>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查询</a-button>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查询区域-END -->


    <!-- table区域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已选择 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>项
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

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
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无图片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下载
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

  export default {
    name: 'OsInstanceList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
    },
    data () {
      return {
        description: '申請明細檔管理页面',
        // 表头
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
            dataIndex: 'instanceName',
            scopedSlots: { customRender: 'instanceName' }
          },
          {
            title:'狀態',
            align:"center",
            dataIndex: 'status'
          },
          {
            title:'鏡像名稱',
            align:"center",
            dataIndex: 'imgName'
          },
          {
            title:'實例類型',
            align:"center",
            dataIndex: 'flavorName'
          },
          {
            title:'實例配置',
            align:"center",
            dataIndex: 'configureInfo'
          },
          {
            title:'IP地址',
            align:"center",
            dataIndex: 'ipAddress'
          },
          {
            title:'所屬項目',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'運行時長',
            align:"center",
            dataIndex: 'runTime'
          },
        ],
        url: {
          list: "/openstack/osInstance/list",
          delete: "/openstack/osInstance/delete",
          deleteBatch: "/openstack/osInstance/deleteBatch",
          exportXlsUrl: "/openstack/osInstance/exportXls",
          importExcelUrl: "openstack/osInstance/importExcel",

        },
        dictOptions:{},
        superFieldList:[],
      }
    },
    created() {
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

    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>