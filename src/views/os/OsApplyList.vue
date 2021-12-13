<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="實例名稱">
              <a-input placeholder="請輸入實例名稱" v-model="queryParam.instanceName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="映像檔">
              <a-input placeholder="請輸入映像檔" v-model="queryParam.imgName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展開' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">申請</a-button>
      <a-button @click="handleSubmit" type="primary" icon="plus">提交</a-button>
      <a-button @click="handleAdjust" type="primary" icon="plus">調整</a-button>
      <!--<a-button type="primary" icon="download" @click="handleExportXls('申請明細檔')">導出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">導入</a-button>
      </a-upload>-->
      <!-- 高級查詢區域 -->
     <!-- <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table區域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
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
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
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

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">編輯</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">詳情</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="確定刪除嗎?" @confirm="() => handleDelete(record.id)">
                  <a>刪除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-apply-modal ref="modalForm" @ok="modalFormOk"></os-apply-modal>
    <os-adjust-modal ref="adjustModal" @ok="modalFormOk"></os-adjust-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import OsApplyModal from './modules/OsApplyModal'
  import { httpAction, getAction } from '@/api/manage'
  import OsAdjustModal from './modules/OsAdjustModal'


  export default {
    name: 'OsApplyList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsApplyModal,
      OsAdjustModal
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
            dataIndex: 'instanceName'
          },
          {
            title:'申請類型',
            align:"center",
            dataIndex: 'options_dictText'
          },
          {
            title:'狀態',
            align:"center",
            dataIndex: 'status_dictText'
          },
          {
            title:'映像檔',
            align:"center",
            dataIndex: 'imgName'
          },
          {
            title:'虛擬硬體樣板',
            align:"center",
            dataIndex: 'flavorName'
          },
          {
            title:'開始時間',
            align:"center",
            dataIndex: 'startTime'
          },
          {
            title:'終止時間',
            align:"center",
            dataIndex: 'endTime'
          },
          {
            title:'剩餘天數',
            align:"center",
            dataIndex: 'sectionTime'
          },
          {
            title:'所屬專案',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'運行狀態',
            align:"center",
            dataIndex: 'runStatus_dictText'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "/os/osApply/list",
          delete: "/os/osApply/delete",
          deleteBatch: "/os/osApply/deleteBatch",
          exportXlsUrl: "/os/osApply/exportXls",
          importExcelUrl: "os/osApply/importExcel",
          submit: "/os/osApply/submit"
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
      searchReset() {//重置
        this.queryParam = {}
        this.selectedRowKeys = [];//清空已勾选的
        this.selectionRows = [];
        this.loadData();
      },
      searchQuery() {//查询
        this.selectedRowKeys = [];//清空已勾选的
        this.selectionRows = [];
        this.loadData();
      },
      handleSubmit(){
        var params = this.selectionRows[0] ;
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('請選擇一條記錄！');
          return false;
        }else if(params.status!=null){
          this.$message.warning('該記錄已申請！');
        }else{
          const that = this;
          let method = "put";
          let httpurl = this.url.submit;
          httpAction(httpurl,params,method).then((res)=>{
            if(res.success){
              that.$message.success(res.message);
              that.$emit('ok');
              that.loadData();
            }else{
              that.$message.warning(res.message);
            }
          })
        }

      },
      handleAdjust(){
        debugger
        const that = this;
        var params = this.selectionRows[0] ;
        debugger;
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('請選擇一條記錄！');
          return false;
        }else if(params.status!="1"){
          this.$message.warning('請先審核！');
        }else{
          this.$refs.adjustModal.adjust(params);
        }
      },
      modalFormOk(){
        this.$nextTick(()=>{
          this.loadData();
        })
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'instanceName',text:'實例名稱',dictCode:''})
        fieldList.push({type:'string',value:'options',text:'申請狀態',dictCode:''})
        fieldList.push({type:'string',value:'status',text:'狀態',dictCode:''})
        fieldList.push({type:'string',value:'represent',text:'描述',dictCode:''})
        fieldList.push({type:'string',value:'imgId',text:'映像檔id',dictCode:''})
        fieldList.push({type:'string',value:'isDelete',text:'刪除實例時是否刪除卷',dictCode:''})
        fieldList.push({type:'string',value:'flavorId',text:'虛擬硬體樣板id',dictCode:''})
        fieldList.push({type:'string',value:'runStatus',text:'運行狀態',dictCode:''})
        fieldList.push({type:'date',value:'startTime',text:'開始時間'})
        fieldList.push({type:'date',value:'endTime',text:'結束時間'})
        fieldList.push({type:'string',value:'securityName',text:'安全群組',dictCode:''})
        fieldList.push({type:'string',value:'networkId',text:'網路',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>